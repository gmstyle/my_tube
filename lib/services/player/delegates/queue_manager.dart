part of '../mt_player_service.dart';

/// Gestisce la playlist e tutte le operazioni sulla coda di riproduzione.
class QueueManager {
  QueueManager(this._service);
  final MtPlayerService _service;

  static const int maxQueueSize = 200;

  List<MediaItem> playlist = [];
  int currentIndex = -1;
  MediaItem? currentTrack;

  bool get hasNextVideo => currentIndex < playlist.length - 1;

  // Token per proteggere dalla race condition: se l'utente tappa più video
  // rapidamente, solo l'ultimo fetch "vince". Ogni chiamata a startPlaying()
  // invalida quella precedente prima di attendere la rete.
  Object? _currentPlayToken;

  // ============ Start Playing ============

  // Avvia la riproduzione di un singolo video.
  //
  // Struttura overlap-mode: il pre-warm dell'URL e il fetch dei metadata
  // avvengono mentre il video corrente suona ancora, quindi lo stop avviene
  // solo quando tutto è pronto. Il token annulla le richieste stale se
  // l'utente tappa un nuovo video prima che questa finisca.
  Future<void> startPlaying(String id, {bool getRelatedVideos = true}) async {
    final token = Object();
    _currentPlayToken = token;

    // 1. Pre-warm AppCache in parallelo con il fetch dei metadata.
    //    getStreamUrl() salva il risultato in AppCache (TTL 1h); quando
    //    _doPlay lo chiamerà pochi ms dopo, troverà un cache hit.
    unawaited(() async {
      try {
        await _service._engine.getStreamUrl(id);
      } catch (e) {
        dev.log('startPlaying: pre-warm URL fallito per $id: $e');
      }
    }());

    try {
      MediaItem? item;
      final existingIndex = playlist.indexWhere((e) => e.id == id);

      if (existingIndex != -1) {
        item = playlist[existingIndex];
        dev.log('Item trovato in cache locale alla posizione $existingIndex');
      } else {
        dev.log('Fetching video metadata for: $id');
        item = await _service._engine.createMediaItem(id);
      }

      if (_currentPlayToken != token) {
        dev.log('startPlaying: token invalidato, skip per id=$id');
        return;
      }

      dev.log('Stopping previous playback...');
      await _service.stop();

      if (_currentPlayToken != token) {
        dev.log('startPlaying: token invalidato dopo stop, skip per id=$id');
        return;
      }

      // Inserimento "Up Next". Se è un nuovo video, inseriscilo dopo il brano corrente
      if (existingIndex == -1) {
        final insertIndex = currentIndex >= 0 ? currentIndex + 1 : 0;
        playlist.insert(insertIndex, item);
        _service.queue.add(playlist);
      }

      // Record in play history (fire-and-forget — Hive write is fast)
      // ignore: unawaited_futures
      // Record in play history
      unawaited(
          _service.favoriteRepository?.addRecentlyPlayed(id) ?? Future.value());

      await _service._engine.playAtIndex(playlist.indexOf(item));

      // Carica in background i video correlati e appendili alla coda.
      if (getRelatedVideos) {
        unawaited(_loadRelatedVideosInBackground(id, token));
      }
    } catch (e) {
      dev.log('Errore in startPlaying per id=$id: $e');

      // In caso di errore, resetto lo stato del player per evitare di rimanere bloccati in uno stato incoerente.
      await _service.stop();
      currentIndex = -1;
      currentTrack = null;
      _service.mediaItem.add(null);
      _service.playbackState.add(_service.playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ));
    }
  }

  // Inizializza il player per la riproduzione di una coda di video
  Future<void> startPlayingPlaylist(
    List<String> ids, {
    Function(int current, int total)? onProgress,
    VoidCallback? onFirstVideoReady,
  }) async {
    final token = Object();
    _currentPlayToken = token;

    // Pre-warm AppCache del primo video in parallelo.
    unawaited(() async {
      try {
        await _service._engine.getStreamUrl(ids.first);
      } catch (e) {
        dev.log('startPlayingPlaylist: pre-warm URL fallito: $e');
      }
    }());

    final firstItem = await _service._engine.createMediaItem(ids.first);

    if (_currentPlayToken != token) {
      dev.log('startPlayingPlaylist: token invalidato, skip');
      return;
    }

    if (!playlist.contains(firstItem)) {
      playlist.add(firstItem);
    }

    await _service._engine.playAtIndex(playlist.indexOf(firstItem));

    onFirstVideoReady?.call();

    if (ids.length > 1) {
      final maxToLoad = min(maxQueueSize - 1, ids.length - 1);
      final remainingIds = ids.sublist(1, min(ids.length, maxToLoad + 1));

      try {
        await _loadVideosInIsolate(remainingIds, onProgress, token);
      } catch (e) {
        dev.log('Errore nell\'isolate, fallback a caricamento sequenziale: $e');
        await _loadVideosSequentially(remainingIds, onProgress,
            offset: 2, token: token);
      }
    }
  }

  /// Carica i video usando un isolato separato (non blocca la UI)
  Future<void> _loadVideosInIsolate(
    List<String> videoIds,
    Function(int current, int total)? onProgress,
    Object token,
  ) async {
    await BulkVideoLoader.loadVideosInIsolate(
      videoIds: videoIds,
      onProgress: (current, total) {
        dev.log('Loading background: $current/$total');
      },
      onItemLoaded: (item) {
        if (_currentPlayToken != token) return;
        if (!playlist.contains(item)) {
          playlist.add(item);
          _service.queue.add(playlist);
        }
      },
    );

    if (_currentPlayToken == token) {
      _service.queue.add(playlist);
    }
  }

  /// Carica i video sequenzialmente sul main thread (fallback)
  Future<void> _loadVideosSequentially(
    List<String> videoIds,
    Function(int current, int total)? onProgress, {
    int offset = 0,
    required Object token,
  }) async {
    for (int i = 0; i < videoIds.length; i++) {
      if (_currentPlayToken != token) return;
      final item = await _service._engine.createMediaItem(videoIds[i]);

      if (_currentPlayToken != token) return;
      if (!playlist.contains(item)) {
        playlist.add(item);
      }

      onProgress?.call(i + offset, videoIds.length + offset - 1);
    }

    if (_currentPlayToken == token) {
      _service.queue.add(playlist);
    }
  }

  // ============ Queue Operations ============

  Future<void> addToQueue(String id) async {
    if (playlist.length >= maxQueueSize) {
      // svuota la coda per fare spazio al nuovo video e ricomincia il caricamento da zero, invece di rifiutare l'aggiunta o sovraccaricare la coda.
      dev.log(
          'Coda piena, svuotamento in corso per fare spazio al nuovo video.');
      await stopPlayingAndClearQueue();
    }

    final item = await _service._engine.createMediaItem(id);

    if (!playlist.contains(item)) {
      playlist.add(item);
      _service.queue.add(playlist);

      // Pre-warm AppCache: quando toccherà a questo video, getStreamUrl()
      // troverà un cache hit invece di andare in rete.
      unawaited(() async {
        try {
          await _service._engine.getStreamUrl(id);
        } catch (e) {
          dev.log('Errore pre-warm cache per queued track $id: $e');
        }
      }());

      if (currentIndex == -1) {
        await _service._engine.playAtIndex(playlist.length - 1);
      }
    }
  }

  Future<void> addAllToQueue(
    List<String> ids, {
    Function(int current, int total)? onProgress,
  }) async {
    // Verifica il limite della coda
    int remainingSpace = maxQueueSize - playlist.length;
    if (remainingSpace <= 0) {
      // Svuota la coda per fare spazio ai nuovi video e ricomincia il caricamento da zero, invece di rifiutare l'aggiunta o sovraccaricare la coda.
      dev.log(
          'Coda piena, svuotamento in corso per fare spazio ai nuovi video.');
      await stopPlayingAndClearQueue();
      remainingSpace = maxQueueSize;
    }

    // Limita il numero di video da aggiungere allo spazio rimanente
    final idsToAdd = ids.take(remainingSpace).toList();
    const batchSize = 8;

    int? firstAddedIndex;
    int loaded = 0;

    // Caricamento in batch paralleli per ridurre la latenza totale
    for (int batchStart = 0;
        batchStart < idsToAdd.length;
        batchStart += batchSize) {
      final batchEnd = min(batchStart + batchSize, idsToAdd.length);
      final batch = idsToAdd.sublist(batchStart, batchEnd);

      final items = await Future.wait(
        batch.map((id) => _service._engine.createMediaItem(id)),
      );

      for (final item in items) {
        if (!playlist.contains(item)) {
          playlist.add(item);
          firstAddedIndex ??= playlist.length - 1;
        }
        loaded++;
        onProgress?.call(loaded, idsToAdd.length);
      }
    }

    _service.queue.add(playlist);

    if (currentIndex == -1 && firstAddedIndex != null) {
      await _service._engine.playAtIndex(firstAddedIndex);
    }
  }

  Future<int?> insertMediaItemsNext(List<MediaItem> items) async {
    if (items.isEmpty) return null;

    if (playlist.length >= maxQueueSize) {
      // Svuota una sola volta: evita stop/ripartenze ripetute durante il loop.
      dev.log(
          'Coda piena, svuotamento in corso per fare spazio ai nuovi video.');
      await stopPlayingAndClearQueue();
    }

    final existingIds = playlist.map((item) => item.id).toSet();
    var insertIndex = currentIndex >= 0 ? currentIndex + 1 : playlist.length;
    int? firstInsertedIndex;

    for (final item in items) {
      if (playlist.length >= maxQueueSize) {
        dev.log(
            'Raggiunto limite coda durante insertMediaItemsNext, stop inserimento.');
        break;
      }
      if (existingIds.contains(item.id)) {
        continue;
      }
      playlist.insert(insertIndex, item);
      existingIds.add(item.id);
      firstInsertedIndex ??= insertIndex;
      insertIndex++;
    }

    if (firstInsertedIndex != null) {
      _service.queue.add(playlist);
    }

    return firstInsertedIndex;
  }

  Future<void> startIfIdle(int? firstInsertedIndex) async {
    if (currentIndex == -1 && firstInsertedIndex != null) {
      await _service._engine.playAtIndex(firstInsertedIndex);
    }
  }

  /// Rimuove un video dalla coda.
  ///
  /// Gestisce tre casi:
  /// 1. Rimuovo video non corrente → solo rimuovi
  /// 2. Rimuovo video corrente con altri video in coda → passa al prossimo (o precedente)
  /// 3. Rimuovo ultimo video → stop playback, clear media item, queue vuota
  ///
  /// Returns:
  /// - `true`: video rimosso, altri video presenti in coda
  /// - `false`: video rimosso, coda ora vuota
  /// - `null`: video non trovato nella coda
  Future<bool?> removeFromQueue(String id) async {
    final index = playlist.indexWhere((element) => element.id == id);

    if (index == -1) {
      return null;
    }

    final bool isCurrentTrack = index == currentIndex;
    final bool wasOnlyTrack = playlist.length == 1;

    // Caso 1: Rimuovo video non corrente → solo rimuovi
    if (!isCurrentTrack) {
      playlist.removeAt(index);
      // Aggiorna currentIndex se necessario
      if (index < currentIndex) {
        currentIndex--;
      }
      _service.queue.add(playlist);
      return true;
    }

    // Caso 2 & 3: Rimuovo video corrente
    playlist.removeAt(index);
    _service.queue.add(playlist);

    // Caso 3: Era l'unico video → stop e clear
    if (wasOnlyTrack) {
      await _service.stop();
      await _service._engine.disposeControllers();
      currentIndex = -1;
      currentTrack = null;
      _service.mediaItem.add(null);
      _service.playbackState.add(_service.playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ));
      return false;
    }

    // Caso 2: Ci sono altri video → passa al prossimo o precedente
    if (playlist.isNotEmpty) {
      currentIndex = index < playlist.length ? index : playlist.length - 1;
      await _service._engine.playAtIndex(currentIndex);
      return true;
    }

    // Fallback (non dovrebbe mai accadere)
    await _service.stop();
    currentIndex = -1;
    currentTrack = null;
    _service.mediaItem.add(null);
    return false;
  }

  Future<void> clearQueue() async {
    playlist.clear();
    currentIndex = -1;
    currentTrack = null;
    _service.queue.add([]);
  }

  Future<void> stopPlayingAndClearQueue() async {
    await stopPlayingAndClearMediaItem();
    await clearQueue();
  }

  Future<void> stopPlayingAndClearMediaItem() async {
    await _service.stop();
    currentIndex = -1;
    currentTrack = null;
    _service.mediaItem.add(null);
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final MediaItem item = playlist.removeAt(oldIndex);
    playlist.insert(newIndex, item);
    _service.queue.add(playlist);
    if (currentIndex == oldIndex) {
      currentIndex = newIndex;
    } else if (oldIndex < currentIndex && currentIndex <= newIndex) {
      currentIndex--;
    } else if (oldIndex > currentIndex && currentIndex >= newIndex) {
      currentIndex++;
    }
  }

  // ============ Related Videos Autoplay ============

  /// Recupera i video correlati per [id] e li appende in background alla coda.
  /// [token] è lo stesso usato in [startPlaying]: se l'utente ha tappato un altro
  /// video nel frattempo il token cambia e il caricamento viene annullato.
  Future<void> _loadRelatedVideosInBackground(String id, Object token) async {
    try {
      // Non caricare correlati se la coda dopo il brano corrente è già corposa
      final remainingTracks = playlist.length - (currentIndex + 1);
      if (remainingTracks >= relatedVideosQueueSize) {
        dev.log(
            'Coda già sufficientemente lunga ($remainingTracks brani), salto caricamento correlati.');
        return;
      }
      final repo = _service.youtubeExplodeRepository;
      if (repo == null) return;

      dev.log('Caricamento video correlati per: $id');
      final relatedTiles = await repo.getRelatedVideos(id);

      // Se l'utente ha già tappato un altro video, annulla
      if (_currentPlayToken != token) {
        dev.log(
            '_loadRelatedVideosInBackground: token invalidato, skip per id=$id');
        return;
      }

      final existingIds = playlist.map((item) => item.id).toSet();
      final toAdd = relatedTiles
          .where((tile) => !existingIds.contains(tile.id))
          .take(relatedVideosQueueSize - remainingTracks)
          .map(PlaybackEngine.mediaItemFromVideoTile)
          .toList();

      if (toAdd.isEmpty) return;

      final remainingSpace = maxQueueSize - playlist.length;
      final capped = toAdd.take(remainingSpace).toList();

      for (final item in capped) {
        playlist.add(item);
      }
      _service.queue.add(playlist);
      dev.log('Aggiunti ${capped.length} video correlati alla coda per: $id');
    } catch (e) {
      dev.log('Errore durante il caricamento dei video correlati: $e');
    }
  }
}

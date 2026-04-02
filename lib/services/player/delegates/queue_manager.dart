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

  // Inizializza il player per la riproduzione singola
  Future<void> startPlaying(String id) async {
    // Crea un token unico per questa invocazione
    final token = Object();
    _currentPlayToken = token;

    // Fetch PRIMA di fermare: il video corrente continua a suonare durante
    // il fetch (cache hit ~50-200ms, miss ~500-1500ms), eliminando lo schermo
    // nero. Con la cache attiva l'overlap è impercettibile.
    dev.log('Fetching new video metadata (overlap mode)...');
    final item =
        await _service._engine.createMediaItem(id, loadStreamUrl: true);

    // Se nel frattempo l'utente ha tappato un altro video, abbandona
    if (_currentPlayToken != token) {
      dev.log('startPlaying: token invalidato, skip per id=$id');
      return;
    }

    // Ora ferma il vecchio video e sostituisci immediatamente
    dev.log('Stopping previous playback...');
    await _service.stop();

    // Secondo controllo: stop() è async, potrebbe arrivare un'altra richiesta
    if (_currentPlayToken != token) {
      dev.log('startPlaying: token invalidato dopo stop, skip per id=$id');
      return;
    }

    // aggiungi il brano alla coda se non è già presente
    if (!playlist.contains(item)) {
      playlist.add(item);
    }

    currentIndex = playlist.indexOf(item);

    // Record in play history (fire-and-forget — Hive write is fast)
    // ignore: unawaited_futures
    _service.favoriteRepository?.addRecentlyPlayed(id);

    await _service._engine.playCurrentTrack();
  }

  // Inizializza il player per la riproduzione di una coda di video
  Future<void> startPlayingPlaylist(
    List<String> ids, {
    Function(int current, int total)? onProgress,
    VoidCallback? onFirstVideoReady,
  }) async {
    // Carica il primo video con lo stream URL per avviare subito la riproduzione
    final firstItem =
        await _service._engine.createMediaItem(ids.first, loadStreamUrl: true);

    if (!playlist.contains(firstItem)) {
      playlist.add(firstItem);
    }

    currentIndex = playlist.indexOf(firstItem);

    // Avvia la riproduzione del primo video
    await _service._engine.playCurrentTrack();

    // Notifica che il primo video è pronto (nasconde il progresso nella UI)
    onFirstVideoReady?.call();

    // Carica gli altri video in background senza stream URL
    if (ids.length > 1) {
      // Limita il caricamento al massimo consentito (maxQueueSize - 1 per il primo video già caricato)
      final maxToLoad = min(maxQueueSize - 1, ids.length - 1);
      final remainingIds = ids.sublist(1, min(ids.length, maxToLoad + 1));

      // Tenta di usare l'isolate per il caricamento in background
      try {
        await _loadVideosInIsolate(remainingIds, onProgress);
      } catch (e) {
        dev.log('Errore nell\'isolate, fallback a caricamento sequenziale: $e');
        // Fallback: caricamento sequenziale sul main thread
        await _loadVideosSequentially(remainingIds, onProgress, offset: 2);
      }
    }
  }

  /// Carica i video usando un isolato separato (non blocca la UI)
  Future<void> _loadVideosInIsolate(
    List<String> videoIds,
    Function(int current, int total)? onProgress,
  ) async {
    await BulkVideoLoader.loadVideosInIsolate(
      videoIds: videoIds,
      onProgress: (current, total) {
        // Il progresso viene ignorato nella UI (onFirstVideoReady già chiamato)
        // ma possiamo loggarlo per debug
        dev.log('Loading background: $current/$total');
      },
      onItemLoaded: (item) {
        // Aggiungi ogni item alla playlist man mano che viene caricato
        if (!playlist.contains(item)) {
          playlist.add(item);
          _service.queue.add(playlist);
        }
      },
    );

    // Aggiorna la coda finale
    _service.queue.add(playlist);
  }

  /// Carica i video sequenzialmente sul main thread (fallback)
  Future<void> _loadVideosSequentially(
    List<String> videoIds,
    Function(int current, int total)? onProgress, {
    int offset = 0,
  }) async {
    for (int i = 0; i < videoIds.length; i++) {
      final item = await _service._engine
          .createMediaItem(videoIds[i], loadStreamUrl: false);

      if (!playlist.contains(item)) {
        playlist.add(item);
      }

      // Notifica il progresso (se fornito)
      onProgress?.call(i + offset, videoIds.length + offset - 1);
    }

    _service.queue.add(playlist);
  }

  // ============ Queue Operations ============

  Future<void> addToQueue(String id) async {
    // Verifica il limite della coda
    if (playlist.length >= maxQueueSize) {
      throw Exception('Coda piena (max $maxQueueSize video)');
    }

    final item =
        await _service._engine.createMediaItem(id, loadStreamUrl: false);

    // aggiungi il brano alla coda se non è già presente
    if (!playlist.contains(item)) {
      playlist.add(item);
      _service.queue.add(playlist);

      // Pre-fetch dello stream URL in background: quando toccherà a questo
      // video nella coda, l'URL sarà già pronto e la transizione sarà istantanea
      if (currentIndex != -1) {
        final itemIndex = playlist.length - 1;
        unawaited(_service._engine.getStreamUrl(id).then((url) {
          if (itemIndex < playlist.length && playlist[itemIndex].id == id) {
            playlist[itemIndex] = playlist[itemIndex].copyWith(
              extras: {
                ...playlist[itemIndex].extras ?? {},
                'streamUrl': url,
              },
            );
            _service.queue.add(playlist);
            dev.log('Pre-fetched stream URL for queued track: $id');
          }
        }).catchError((e) {
          dev.log('Errore pre-fetching queued track $id: $e');
        }));
      }

      // se non è stato ancora inizializzato il player, inizializzalo e riproduci il brano
      if (currentIndex == -1) {
        currentIndex = playlist.length - 1;
        await _service._engine.playCurrentTrack();
      }
    }
  }

  Future<void> addAllToQueue(
    List<String> ids, {
    Function(int current, int total)? onProgress,
  }) async {
    // Verifica il limite della coda
    final remainingSpace = maxQueueSize - playlist.length;
    if (remainingSpace <= 0) {
      throw Exception('Coda piena (max $maxQueueSize video)');
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
        batch.map((id) =>
            _service._engine.createMediaItem(id, loadStreamUrl: false)),
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
      currentIndex = firstAddedIndex;
      await _service._engine.playCurrentTrack();
    }
  }

  Future<int?> insertMediaItemsNext(List<MediaItem> items) async {
    if (items.isEmpty) return null;

    final existingIds = playlist.map((item) => item.id).toSet();
    var insertIndex = currentIndex >= 0 ? currentIndex + 1 : playlist.length;
    int? firstInsertedIndex;

    for (final item in items) {
      if (playlist.length >= maxQueueSize) {
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
      currentIndex = firstInsertedIndex;
      await _service._engine.playCurrentTrack();
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
      // Determina il nuovo indice: preferibilmente lo stesso indice (prossimo video)
      // se ero all'ultimo, vai al precedente
      currentIndex = index < playlist.length ? index : playlist.length - 1;

      // Avvia il nuovo video corrente
      await _service._engine.chewieController?.videoPlayerController
          .seekTo(Duration.zero);
      await _service._engine.playCurrentTrack();
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
    //await _disposeControllers();
    playlist.clear();
    _service.queue.value.clear();
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
}

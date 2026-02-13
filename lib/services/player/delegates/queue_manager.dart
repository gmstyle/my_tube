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

  // ============ Start Playing ============

  // Inizializza il player per la riproduzione singola
  Future<void> startPlaying(String id) async {
    // inizializza il media item da passare riprodurre con stream URL
    final item =
        await _service._engine.createMediaItem(id, loadStreamUrl: true);

    // aggiungi il brano alla coda se non è già presente
    if (!playlist.contains(item)) {
      playlist.add(item);
    }

    currentIndex = playlist.indexOf(item);

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

    int? firstAddedIndex;

    for (int i = 0; i < idsToAdd.length; i++) {
      final item =
          await _service._engine.createMediaItem(ids[i], loadStreamUrl: false);

      if (!playlist.contains(item)) {
        playlist.add(item);
        firstAddedIndex ??= playlist.length - 1;
      }

      // Notifica il progresso
      onProgress?.call(i + 1, idsToAdd.length);
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

  Future<bool?> removeFromQueue(String id) async {
    final index = playlist.indexWhere((element) => element.id == id);

    if (index == -1) {
      return null;
    }

    if (index < currentIndex) {
      currentIndex--;
    } else if (index == currentIndex) {
      playlist.removeAt(index);
      _service.queue.add(playlist);

      if (playlist.isNotEmpty) {
        currentIndex = index < playlist.length ? index : playlist.length - 1;
        await _service._engine.chewieController?.videoPlayerController
            .seekTo(Duration.zero);
        await _service._engine.playCurrentTrack();
        return true;
      } else {
        _service.stop();
        currentIndex = -1;
        currentTrack = null;
        _service.mediaItem.add(null);
        return false;
      }
    } else {
      currentIndex = playlist.indexOf(currentTrack!);
    }

    playlist.removeAt(index);
    _service.queue.add(playlist);

    return true;
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

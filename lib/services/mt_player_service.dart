import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/respositories/favorite_repository.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/services/android_auto_content_helper.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:my_tube/providers/youtube_explode_provider.dart';
import 'package:my_tube/services/android_auto_detection_service.dart';
import 'package:my_tube/services/bulk_video_loader.dart';
import 'package:my_tube/ui/views/video/widget/full_screen_video_view.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MtPlayerService extends BaseAudioHandler with QueueHandler, SeekHandler {
  MtPlayerService({
    required this.youtubeExplodeProvider,
    this.favoriteRepository,
    this.youtubeExplodeRepository,
  });

  static const int maxQueueSize = 200;

  final YoutubeExplodeProvider youtubeExplodeProvider;
  final FavoriteRepository? favoriteRepository;
  final YoutubeExplodeRepository? youtubeExplodeRepository;
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  int currentIndex = -1;
  MediaItem? currentTrack;
  List<MediaItem> playlist = [];
  bool get hasNextVideo => currentIndex < playlist.length - 1;
  final random = Random();
  bool get isShuffleModeEnabled =>
      playbackState.value.shuffleMode == AudioServiceShuffleMode.all;
  final playedIndexesInShuffleMode = <int>[];
  bool get allVideosPlayed =>
      playedIndexesInShuffleMode.length == playlist.length;

  bool get isRepeatModeAllEnabled =>
      playbackState.value.repeatMode == AudioServiceRepeatMode.all;

  // Stream per notificare il cambio di brano alla UI FullScreenView
  final StreamController<void> skipController =
      StreamController<void>.broadcast();
  Stream<void> get onSkip => skipController.stream;

  // Flag per gestire lo stato di Android Auto
  bool _isAndroidAutoActive = false;

  /// Inizializza il rilevamento di Android Auto
  Future<void> initializeAndroidAutoDetection() async {
    try {
      await AndroidAutoDetectionService.initialize();
      _isAndroidAutoActive =
          await AndroidAutoDetectionService.isAndroidAutoActive();
      dev.log('Android Auto stato iniziale: $_isAndroidAutoActive');

      // Aggiorna periodicamente lo stato di Android Auto
      Timer.periodic(const Duration(seconds: 5), (timer) async {
        try {
          final newState =
              await AndroidAutoDetectionService.isAndroidAutoActive();
          if (newState != _isAndroidAutoActive) {
            dev.log(
                'Cambio stato Android Auto: $_isAndroidAutoActive -> $newState');
            _isAndroidAutoActive = newState;
            // Aggiorna la configurazione audio se necessario
            await _updateAudioConfigurationForAndroidAuto();
          }
        } catch (e) {
          dev.log(
              'Errore durante l\'aggiornamento dello stato Android Auto: $e');
        }
      });
    } catch (e) {
      dev.log(
          'Errore durante l\'inizializzazione del rilevamento Android Auto: $e');
      _isAndroidAutoActive = false;
    }
  }

  /// Aggiorna la configurazione audio per Android Auto
  Future<void> _updateAudioConfigurationForAndroidAuto() async {
    try {
      if (_isAndroidAutoActive) {
        dev.log('Configurazione audio per Android Auto attivata');
        // Configura le impostazioni audio specifiche per Android Auto
        playbackState.add(playbackState.value.copyWith(
          androidCompactActionIndices: const [
            0,
            1,
            3
          ], // Azioni compatte per Android Auto
          systemActions: const {
            MediaAction.seek,
            MediaAction.skipToPrevious,
            MediaAction.skipToNext,
          },
        ));
      }
    } catch (e) {
      dev.log(
          'Errore durante l\'aggiornamento della configurazione audio per Android Auto: $e');
    }
  }

  /// Ottiene lo stato corrente di Android Auto
  bool get isAndroidAutoActive => _isAndroidAutoActive;

  /// Forza l'aggiornamento dello stato di Android Auto
  Future<void> refreshAndroidAutoState() async {
    try {
      _isAndroidAutoActive =
          await AndroidAutoDetectionService.refreshAndroidAutoState();
      dev.log('Stato Android Auto aggiornato: $_isAndroidAutoActive');
      await _updateAudioConfigurationForAndroidAuto();
    } catch (e) {
      dev.log(
          'Errore durante l\'aggiornamento forzato dello stato Android Auto: $e');
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    try {
      playedIndexesInShuffleMode.clear();
      playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
    } catch (e) {
      dev.log('Errore durante setShuffleMode: $e');
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    try {
      await _setRepeatMode(repeatMode);
    } catch (e) {
      dev.log('Errore durante setRepeatMode: $e');
    }
  }

  @override
  Future<void> play() async {
    try {
      await chewieController?.videoPlayerController.play();
    } catch (e) {
      dev.log('Errore durante play: $e');
      // Fallback per Android Auto
      if (_isAndroidAutoActive) {
        await _handleAndroidAutoPlayback();
      }
    }
  }

  @override
  Future<void> pause() async {
    try {
      await chewieController?.videoPlayerController.pause();
    } catch (e) {
      dev.log('Errore durante pause: $e');
    }
  }

  @override
  Future<void> stop() async {
    await chewieController?.videoPlayerController.pause();
    await chewieController?.videoPlayerController.seekTo(Duration.zero);
  }

  @override
  Future<void> seek(Duration position) async {
    await chewieController?.videoPlayerController.seekTo(position);
  }

  @override
  Future<void> skipToPrevious() async {
    if (currentIndex > 0) {
      currentIndex--;
      await chewieController?.videoPlayerController.seekTo(Duration.zero);
      await _playCurrentTrack();
      skipController.add(null);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      await chewieController?.videoPlayerController.seekTo(Duration.zero);
      await _playCurrentTrack();
      skipController.add(null);
    }
  }

  Future<void> skipToNextInShuffleMode() async {
    // se è attivo il repeat mode all, quando la lista playedIndexesInShuffleMode è piena, svuotala
    if (isRepeatModeAllEnabled) {
      if (playedIndexesInShuffleMode.length == playlist.length) {
        playedIndexesInShuffleMode.clear();
      }
    }

    final randomIndex = random.nextInt(playlist.length);

    if (playedIndexesInShuffleMode.contains(randomIndex)) {
      // se l'indice è già stato riprodotto, riprova a generare un nuovo indice
      skipToNextInShuffleMode();
    } else if (currentIndex != randomIndex) {
      currentIndex = randomIndex;
      playedIndexesInShuffleMode.add(currentIndex);
      await chewieController?.videoPlayerController.seekTo(Duration.zero);
      await _playCurrentTrack();
      skipController.add(null);
    }
  }

  Future<void> skipToNextInRepeatModeAll() async {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      await chewieController?.videoPlayerController.seekTo(Duration.zero);
      await _playCurrentTrack();
      skipController.add(null);
    } else {
      currentIndex = 0;
      await chewieController?.videoPlayerController.seekTo(Duration.zero);
      await _playCurrentTrack();
      skipController.add(null);
    }
  }

  // Inizializza il player per la riproduzione singola
  Future<void> startPlaying(String id) async {
    // inizializza il media item da passare riprodurre con stream URL
    final item = await _createMediaItem(id, loadStreamUrl: true);

    // aggiungi il brano alla coda se non è già presente
    if (!playlist.contains(item)) {
      playlist.add(item);
    }

    currentIndex = playlist.indexOf(item);

    await _playCurrentTrack();
  }

  // Inizializza il player per la riproduzione di una coda di video
  Future<void> startPlayingPlaylist(
    List<String> ids, {
    Function(int current, int total)? onProgress,
    VoidCallback? onFirstVideoReady,
  }) async {
    // Carica il primo video con lo stream URL per avviare subito la riproduzione
    final firstItem = await _createMediaItem(ids.first, loadStreamUrl: true);

    if (!playlist.contains(firstItem)) {
      playlist.add(firstItem);
    }

    currentIndex = playlist.indexOf(firstItem);

    // Avvia la riproduzione del primo video
    await _playCurrentTrack();

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
          queue.add(playlist);
        }
      },
    );

    // Aggiorna la coda finale
    queue.add(playlist);
  }

  /// Carica i video sequenzialmente sul main thread (fallback)
  Future<void> _loadVideosSequentially(
    List<String> videoIds,
    Function(int current, int total)? onProgress, {
    int offset = 0,
  }) async {
    for (int i = 0; i < videoIds.length; i++) {
      final item = await _createMediaItem(videoIds[i], loadStreamUrl: false);

      if (!playlist.contains(item)) {
        playlist.add(item);
      }

      // Notifica il progresso (se fornito)
      onProgress?.call(i + offset, videoIds.length + offset - 1);
    }

    queue.add(playlist);
  }

  // prepara lo stato del player per la riproduzione
  void _broadcastState() {
    try {
      bool isPlaying() =>
          chewieController != null &&
          chewieController!.videoPlayerController.value.isPlaying;

      AudioProcessingState audioProcessingState() {
        if (chewieController == null) return AudioProcessingState.idle;
        final value = chewieController!.videoPlayerController.value;
        if (value.isBuffering) return AudioProcessingState.buffering;
        if (value.isInitialized) return AudioProcessingState.ready;
        return AudioProcessingState.idle;
      }

      // Protezione per Android Auto - evita errori quando il controller non è disponibile
      if (chewieController == null ||
          !chewieController!.videoPlayerController.value.isInitialized) {
        final isBuffering = playbackState.value.processingState ==
            AudioProcessingState.buffering;
        playbackState.add(playbackState.value.copyWith(
          processingState: isBuffering
              ? AudioProcessingState.buffering
              : AudioProcessingState.idle,
          playing: false,
        ));
        return;
      }

      playbackState.add(playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playbackState.value.playing)
              MediaControl.pause
            else
              MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
          },
          androidCompactActionIndices: const [
            0,
            1,
            3
          ],
          processingState: audioProcessingState(),
          playing: isPlaying(),
          updatePosition:
              chewieController!.videoPlayerController.value.position,
          speed: chewieController!.videoPlayerController.value.playbackSpeed,
          queueIndex: currentIndex));
    } catch (e) {
      dev.log('Errore in _broadcastState: $e');
      // Fallback state per Android Auto
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ));
    }
  }

  Future<void> _playCurrentTrack() async {
    dev.log('--- _playCurrentTrack started ---');
    try {
      // Segnala che stiamo caricando (buffering state per Android Auto)
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.buffering,
      ));

      currentTrack = playlist[currentIndex];
      dev.log('Current item: ${currentTrack?.id} - ${currentTrack?.title}');

      // Non settiamo a null se abbiamo già un track (evita schermate nere improvvise)
      if (currentTrack != null) {
        mediaItem.add(currentTrack);
      } else {
        mediaItem.add(null);
      }

      if (chewieController != null && videoPlayerController != null) {
        await _disposeControllers();
      }
      // Carica lo stream URL se non è ancora stato caricato
      if (currentTrack?.extras?['streamUrl'] == null) {
        dev.log('Fetching stream URL for: ${currentTrack?.id}');
        final streamUrl = await _getStreamUrl(currentTrack!.id);
        dev.log('Stream URL fetched successfully');
        currentTrack = currentTrack!.copyWith(
          extras: {
            ...currentTrack!.extras ?? {},
            'streamUrl': streamUrl,
          },
        );
        // Aggiorna anche nella playlist
        playlist[currentIndex] = currentTrack!;
      }

      dev.log('Initializing VideoPlayerController...');
      // inizializza il video player controller da passare a chewie
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(currentTrack?.extras!['streamUrl']),
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
      );

      await videoPlayerController!.initialize();
      dev.log('VideoPlayerController initialized');

      // Forza il play immediato per notifiche e background
      await videoPlayerController!.play();
      dev.log('VideoPlayerController.play() called');

      // inizializza il chewie controller per la riproduzione del video
      dev.log('Creating ChewieController...');
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        showOptions: false,
        routePageBuilder: (context, animation, __, ___) {
          // uso un widget per il full screen personalizzato
          // per poter gestire il cambio di brano anche in full screen
          return FullScreenVideoView(
            mtPlayerService: this,
          );
        },
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );
      dev.log('ChewieController created');

      // inizializza lo stato iniziale
      _broadcastState();

      // aggiungi il brano alla coda
      queue.add(playlist);
      // aggiungi il brano al media item per la notifica
      mediaItem.add(currentTrack);

      // propaga lo stato del player ad audio_service e a tutti i listeners

      chewieController?.videoPlayerController.addListener(() {
        _broadcastState();
        // verifica che il video sia finito
        if (chewieController!.videoPlayerController.value.duration ==
            chewieController!.videoPlayerController.value.position) {
          // verifica che ci siano altri brani nella coda
          if (isShuffleModeEnabled && isRepeatModeAllEnabled) {
            skipToNextInShuffleMode();
          } else if (isShuffleModeEnabled) {
            // Caso in cui è attivo solo lo shuffle mode
            if (allVideosPlayed) {
              stop();
            } else {
              skipToNextInShuffleMode();
            }
          } else if (isRepeatModeAllEnabled) {
            // Caso in cui è attivo solo il repeat all mode
            skipToNextInRepeatModeAll();
          } else {
            // Caso in cui sono entrambi disattivi
            if (hasNextVideo) {
              skipToNext();
            } else {
              stop();
            }
          }
        }

        if (chewieController!.videoPlayerController.value.hasError) {
          if (kDebugMode) {
            print(
                'Errore di riproduzione: ${chewieController!.videoPlayerController.value.errorDescription}');
          }
        }
      });
    } catch (e) {
      dev.log('Errore durante _playCurrentTrack: $e');
      // Fallback per Android Auto - tenta playback semplificato
      if (_isAndroidAutoActive) {
        await _handleAndroidAutoPlayback();
      }
    }
  }

  Future<void> _setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (repeatMode == AudioServiceRepeatMode.one) {
      await chewieController?.videoPlayerController.setLooping(true);
    } else {
      await chewieController?.videoPlayerController.setLooping(false);
    }

    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  Future<void> addToQueue(String id) async {
    // Verifica il limite della coda
    if (playlist.length >= maxQueueSize) {
      throw Exception('Coda piena (max $maxQueueSize video)');
    }

    final item = await _createMediaItem(id, loadStreamUrl: false);

    // aggiungi il brano alla coda se non è già presente
    if (!playlist.contains(item)) {
      playlist.add(item);
      queue.add(playlist);

      // se non è stato ancora inizializzato il player, inizializzalo e riproduci il brano
      if (currentIndex == -1) {
        currentIndex = playlist.length - 1;
        await _playCurrentTrack();
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
      final item = await _createMediaItem(ids[i], loadStreamUrl: false);

      if (!playlist.contains(item)) {
        playlist.add(item);
        firstAddedIndex ??= playlist.length - 1;
      }

      // Notifica il progresso
      onProgress?.call(i + 1, idsToAdd.length);
    }

    queue.add(playlist);

    if (currentIndex == -1 && firstAddedIndex != null) {
      currentIndex = firstAddedIndex;
      await _playCurrentTrack();
    }
  }

  Future<int?> _insertMediaItemsNext(List<MediaItem> items) async {
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
      queue.add(playlist);
    }

    return firstInsertedIndex;
  }

  Future<void> _startIfIdle(int? firstInsertedIndex) async {
    if (currentIndex == -1 && firstInsertedIndex != null) {
      currentIndex = firstInsertedIndex;
      await _playCurrentTrack();
    }
  }

  List<MediaItem> _prependAddAllItem(
    String parentMediaId,
    List<MediaItem> items,
  ) {
    if (items.isEmpty) return items;
    return [
      AndroidAutoContentHelper.getAddAllToQueueItem(parentMediaId),
      ...items,
    ];
  }

  Future<List<MediaItem>> _getPlayableItemsForParent(
      String parentMediaId) async {
    switch (parentMediaId) {
      case AndroidAutoContentHelper.musicNewReleasesId:
        return await _getNewReleases();
      case AndroidAutoContentHelper.musicDiscoverId:
        return await _getDiscoverVideos();
      case AndroidAutoContentHelper.musicTrendingId:
        return await _getTrendingMusic();
      case AndroidAutoContentHelper.favoritesVideosId:
        return await _getFavoriteVideos();
      default:
        if (AndroidAutoContentHelper.isChannelId(parentMediaId)) {
          final channelId =
              AndroidAutoContentHelper.extractChannelId(parentMediaId);
          return await _getChannelVideos(channelId);
        }
        if (AndroidAutoContentHelper.isPlaylistId(parentMediaId)) {
          final playlistId =
              AndroidAutoContentHelper.extractPlaylistId(parentMediaId);
          return await _getPlaylistVideos(playlistId);
        }
        if (AndroidAutoContentHelper.isSearchResultsId(parentMediaId)) {
          final query =
              AndroidAutoContentHelper.extractSearchQuery(parentMediaId);
          return await _getSearchResults(query);
        }
        return [];
    }
  }

  Future<void> _handleAddAllToQueue(String parentMediaId) async {
    final items = await _getPlayableItemsForParent(parentMediaId);
    final firstInsertedIndex = await _insertMediaItemsNext(items);
    await _startIfIdle(firstInsertedIndex);
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
      queue.add(playlist);

      if (playlist.isNotEmpty) {
        currentIndex = index < playlist.length ? index : playlist.length - 1;
        await chewieController?.videoPlayerController.seekTo(Duration.zero);
        await _playCurrentTrack();
        return true;
      } else {
        stop();
        currentIndex = -1;
        currentTrack = null;
        mediaItem.add(null);
        return false;
      }
    } else {
      currentIndex = playlist.indexOf(currentTrack!);
    }

    playlist.removeAt(index);
    queue.add(playlist);

    return true;
  }

  Future<void> clearQueue() async {
    //await _disposeControllers();
    playlist.clear();
    queue.value.clear();
  }

  Future<void> stopPlayingAndClearQueue() async {
    await stopPlayingAndClearMediaItem();
    await clearQueue();
  }

  Future<void> stopPlayingAndClearMediaItem() async {
    await stop();
    currentIndex = -1;
    currentTrack = null;
    mediaItem.add(null);
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final MediaItem item = playlist.removeAt(oldIndex);
    playlist.insert(newIndex, item);
    queue.add(playlist);
    if (currentIndex == oldIndex) {
      currentIndex = newIndex;
    } else if (oldIndex < currentIndex && currentIndex <= newIndex) {
      currentIndex--;
    } else if (oldIndex > currentIndex && currentIndex >= newIndex) {
      currentIndex++;
    }
  }

  Future<MediaItem> _createMediaItem(String id,
      {bool loadStreamUrl = false}) async {
    final video = await youtubeExplodeProvider.getVideo(id);

    String? muxedStream;
    if (loadStreamUrl) {
      final manifest = await youtubeExplodeProvider.getVideoStreamManifest(id);
      muxedStream = manifest.muxed.isNotEmpty
          ? manifest.muxed.withHighestBitrate().url.toString()
          : manifest.audioOnly.withHighestBitrate().url.toString();
    }

    return MediaItem(
        id: video.id.value,
        title: video.title,
        album: video.musicData.isNotEmpty ? video.musicData.first.album : null,
        artUri: Uri.parse(video.thumbnails.highResUrl),
        duration: video.duration,
        extras: {
          'streamUrl': muxedStream,
          'description': video.description,
        });
  }

  Future<String> _getStreamUrl(String id) async {
    final manifest = await youtubeExplodeProvider.getVideoStreamManifest(id);
    return manifest.muxed.isNotEmpty
        ? manifest.muxed.withHighestBitrate().url.toString()
        : manifest.audioOnly.withHighestBitrate().url.toString();
  }

  Future<void> _disposeControllers() async {
    await chewieController?.videoPlayerController.dispose();
    chewieController?.dispose();
    chewieController = null;
    videoPlayerController = null;
  }

  // Metodi specifici per Android Auto
  Future<void> _handleAndroidAutoPlayback() async {
    try {
      // Configurazione specifica per Android Auto
      if (videoPlayerController != null) {
        await videoPlayerController!.initialize();
        await videoPlayerController!.play();
      }
    } catch (e) {
      dev.log('Errore in Android Auto playback: $e');
    }
  }

  // Override per gestire meglio i controlli media quando Android Auto è attivo
  @override
  Future<void> onTaskRemoved() async {
    try {
      if (!_isAndroidAutoActive) {
        await stop();
      }
    } catch (e) {
      dev.log('Errore durante onTaskRemoved: $e');
    }
  }

  @override
  Future<void> onNotificationDeleted() async {
    try {
      if (!_isAndroidAutoActive) {
        await stop();
      }
    } catch (e) {
      dev.log('Errore durante onNotificationDeleted: $e');
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    dev.log('playMediaItem called: ${mediaItem.id}');
    if (AndroidAutoContentHelper.isAddAllToQueueId(mediaItem.id)) {
      final parentId =
          AndroidAutoContentHelper.extractAddAllParentId(mediaItem.id);
      await _handleAddAllToQueue(parentId);
      return;
    }
    if (mediaItem.playable == true) {
      // Se è un video singolo, lo mettiamo in playlist e lo riproduciamo
      playlist = [mediaItem];
      currentIndex = 0;
      currentTrack = mediaItem;
      await _playCurrentTrack();
    } else {
      // Se è una categoria/canale/playlist (browsable), Android Auto dovrebbe navigare,
      // ma se viene "riprodotta" direttamente la trattiamo come "seleziona e riproduci tutto"
      dev.log('Attempting to play browsable item: ${mediaItem.id}');
      // Qui potremmo caricare la lista di video e avviare la riproduzione del primo
    }
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    dev.log('playFromMediaId called: $mediaId');
    if (AndroidAutoContentHelper.isAddAllToQueueId(mediaId)) {
      final parentId = AndroidAutoContentHelper.extractAddAllParentId(mediaId);
      await _handleAddAllToQueue(parentId);
      return;
    }
    // Implementazione speculare a playMediaItem o caricamento dinamico se necessario
    // Per ora, se è un video ID (non ha prefissi), lo riproduciamo
    if (!AndroidAutoContentHelper.isChannelId(mediaId) &&
        !AndroidAutoContentHelper.isPlaylistId(mediaId)) {
      // Carica i dettagli del video se non li abbiamo
      try {
        final videoDetails = await _createMediaItem(mediaId);
        await playMediaItem(videoDetails);
      } catch (e) {
        dev.log('Errore in playFromMediaId: $e');
      }
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    try {
      if (mediaItem.playable == true) {
        final item = await _createMediaItem(mediaItem.id, loadStreamUrl: false);
        final firstInsertedIndex = await _insertMediaItemsNext([item]);
        await _startIfIdle(firstInsertedIndex);
        return;
      }

      final mediaId = mediaItem.id;
      if (AndroidAutoContentHelper.isChannelId(mediaId)) {
        final channelId = AndroidAutoContentHelper.extractChannelId(mediaId);
        final items = await _getChannelVideos(channelId);
        final firstInsertedIndex = await _insertMediaItemsNext(items);
        await _startIfIdle(firstInsertedIndex);
        return;
      }

      if (AndroidAutoContentHelper.isPlaylistId(mediaId)) {
        final playlistId = AndroidAutoContentHelper.extractPlaylistId(mediaId);
        final items = await _getPlaylistVideos(playlistId);
        final firstInsertedIndex = await _insertMediaItemsNext(items);
        await _startIfIdle(firstInsertedIndex);
      }
    } catch (e) {
      dev.log('Errore durante addQueueItem: $e');
    }
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    try {
      if (mediaItems.isEmpty) return;

      final playableItems = <MediaItem>[];
      for (final mediaItem in mediaItems) {
        if (mediaItem.playable == true) {
          final item =
              await _createMediaItem(mediaItem.id, loadStreamUrl: false);
          playableItems.add(item);
        } else if (AndroidAutoContentHelper.isChannelId(mediaItem.id)) {
          final channelId =
              AndroidAutoContentHelper.extractChannelId(mediaItem.id);
          playableItems.addAll(await _getChannelVideos(channelId));
        } else if (AndroidAutoContentHelper.isPlaylistId(mediaItem.id)) {
          final playlistId =
              AndroidAutoContentHelper.extractPlaylistId(mediaItem.id);
          playableItems.addAll(await _getPlaylistVideos(playlistId));
        }
      }

      final firstInsertedIndex = await _insertMediaItemsNext(playableItems);
      await _startIfIdle(firstInsertedIndex);
    } catch (e) {
      dev.log('Errore durante addQueueItems: $e');
    }
  }

  // ============ Android Auto Media Browsing ============

  /// Override per fornire contenuti navigabili ad Android Auto
  @override
  Future<List<MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) async {
    dev.log('--- Android Auto getChildren ---');
    dev.log('ParentMediaId: "$parentMediaId"');
    dev.log('Options: $options');

    try {
      // Gestione ID Root: alcuni sistemi usano '/', altri 'root', ecc.
      if (parentMediaId == AndroidAutoContentHelper.rootId ||
          parentMediaId == 'root' ||
          parentMediaId == 'root_id') {
        dev.log('Returning Root Categories...');
        final root = AndroidAutoContentHelper.getRootCategories();
        dev.log('Root categories count: ${root.length}');
        return root;
      }

      switch (parentMediaId) {
        // Musica: hub esploso
        case AndroidAutoContentHelper.musicId:
          dev.log('Building Exploded Music Hub...');
          final hubItems = <MediaItem>[];

          // Nuove Uscite
          hubItems.add(AndroidAutoContentHelper.getMusicCategoryFolder(
              AndroidAutoContentHelper.musicNewReleasesId, 'New Releases'));
          final newReleases = await _getNewReleases(limit: 6);
          hubItems.addAll(newReleases);

          // Scopri
          hubItems.add(AndroidAutoContentHelper.getMusicCategoryFolder(
              AndroidAutoContentHelper.musicDiscoverId, 'Discover'));
          final discover = await _getDiscoverVideos(limit: 6);
          hubItems.addAll(discover);

          // Trending
          hubItems.add(AndroidAutoContentHelper.getMusicCategoryFolder(
              AndroidAutoContentHelper.musicTrendingId, 'Trending'));
          final trending = await _getTrendingMusic(limit: 6);
          hubItems.addAll(trending);

          return hubItems;

        // Preferiti: hub esploso
        case AndroidAutoContentHelper.favoritesId:
          dev.log('Building Exploded Favorites Hub...');
          final hubItemsFav = <MediaItem>[];

          // Video
          hubItemsFav.add(AndroidAutoContentHelper.getFavoritesCategoryFolder(
              AndroidAutoContentHelper.favoritesVideosId, 'My Videos'));
          final favVideos = await _getFavoriteVideos(limit: 10);
          hubItemsFav.addAll(favVideos);

          // Canali
          hubItemsFav.add(AndroidAutoContentHelper.getFavoritesCategoryFolder(
              AndroidAutoContentHelper.favoritesChannelsId, 'My Channels'));
          final favChannels = await _getFavoriteChannels(limit: 6);
          hubItemsFav.addAll(favChannels);

          // Playlist
          hubItemsFav.add(AndroidAutoContentHelper.getFavoritesCategoryFolder(
              AndroidAutoContentHelper.favoritesPlaylistsId, 'My Playlists'));
          final favPlaylists = await _getFavoritePlaylists(limit: 6);
          hubItemsFav.addAll(favPlaylists);

          return hubItemsFav;

        // Musica > Nuove Uscite (Lista completa)
        case AndroidAutoContentHelper.musicNewReleasesId:
          dev.log('Loading Full New Releases...');
          return _prependAddAllItem(parentMediaId, await _getNewReleases());

        // Musica > Scopri (video correlati ai preferiti)
        case AndroidAutoContentHelper.musicDiscoverId:
          dev.log('Loading Discover Videos...');
          return _prependAddAllItem(parentMediaId, await _getDiscoverVideos());

        // Musica > Trending
        case AndroidAutoContentHelper.musicTrendingId:
          dev.log('Loading Trending Music...');
          return _prependAddAllItem(parentMediaId, await _getTrendingMusic());

        // Preferiti > Video
        case AndroidAutoContentHelper.favoritesVideosId:
          dev.log('Loading Favorite Videos...');
          return _prependAddAllItem(parentMediaId, await _getFavoriteVideos());

        // Preferiti > Canali
        case AndroidAutoContentHelper.favoritesChannelsId:
          dev.log('Loading Favorite Channels...');
          return await _getFavoriteChannels();

        // Preferiti > Playlist
        case AndroidAutoContentHelper.favoritesPlaylistsId:
          dev.log('Loading Favorite Playlists...');
          return await _getFavoritePlaylists();

        // Ricerca > Cronologia ricerche
        case AndroidAutoContentHelper.searchId:
          dev.log('Loading Recent Searches...');
          return await _getRecentSearches();

        default:
          dev.log('Handling dynamic ID: $parentMediaId');
          // Gestione navigazione dinamica (canali, playlist)
          if (AndroidAutoContentHelper.isChannelId(parentMediaId)) {
            final channelId =
                AndroidAutoContentHelper.extractChannelId(parentMediaId);
            dev.log('Loading videos for channel: $channelId');
            return _prependAddAllItem(
                parentMediaId, await _getChannelVideos(channelId));
          }
          if (AndroidAutoContentHelper.isPlaylistId(parentMediaId)) {
            final playlistId =
                AndroidAutoContentHelper.extractPlaylistId(parentMediaId);
            dev.log('Loading videos for playlist: $playlistId');
            return _prependAddAllItem(
                parentMediaId, await _getPlaylistVideos(playlistId));
          }
          if (AndroidAutoContentHelper.isSearchResultsId(parentMediaId)) {
            final query =
                AndroidAutoContentHelper.extractSearchQuery(parentMediaId);
            dev.log('Loading search results for query: $query');
            return _prependAddAllItem(
                parentMediaId, await _getSearchResults(query));
          }
          dev.log('No children found for ID: $parentMediaId');
          return [];
      }
    } catch (e, stack) {
      dev.log('Errore in getChildren: $e');
      dev.log('Stack Trace: $stack');
      return [];
    }
  }

  /// Override per gestire la ricerca vocale di Android Auto
  @override
  Future<List<MediaItem>> search(
    String query, [
    Map<String, dynamic>? extras,
  ]) async {
    dev.log('Android Auto search called with query: $query');

    if (youtubeExplodeRepository == null || query.isEmpty) {
      return [];
    }

    try {
      final result =
          await youtubeExplodeRepository!.searchContents(query: query);
      final items = result['items'] as List<dynamic>;

      // Filtra solo i video per Android Auto (canali e playlist non sono riproducibili direttamente)
      final videos = items.whereType<VideoTile>().take(20).toList();
      return AndroidAutoContentHelper.videoTilesToMediaItems(videos);
    } catch (e) {
      dev.log('Errore in search: $e');
      return [];
    }
  }

  // ============ Metodi di supporto per caricamento dati ============

  Future<List<MediaItem>> _getNewReleases({int? limit}) async {
    try {
      final favoriteChannels = await favoriteRepository!.favoriteChannels;
      if (favoriteChannels.isEmpty) return [];

      final List<VideoTile> newReleases = [];
      for (final channel in favoriteChannels) {
        try {
          final channelData =
              await youtubeExplodeRepository!.getChannel(channel.id);
          final uploads = channelData['videos'] as List<VideoTile>;
          newReleases.addAll(uploads);

          // Se abbiamo un limite e lo abbiamo già superato per questo hub, fermati nel caricarne altri per velocizzare
          if (limit != null && newReleases.length >= limit) break;
        } catch (e) {
          dev.log('Errore caricamento video canale ${channel.id}: $e');
        }
      }

      final result = newReleases.toList();
      return AndroidAutoContentHelper.videoTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getNewReleases: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getDiscoverVideos({int? limit}) async {
    try {
      final favoriteVideos = await favoriteRepository!.favoriteVideos;
      if (favoriteVideos.isEmpty) return [];

      final randomVideo =
          favoriteVideos[Random().nextInt(favoriteVideos.length)];
      final relatedVideos =
          await youtubeExplodeRepository!.getRelatedVideos(randomVideo.id);

      final result = relatedVideos.toList();
      return AndroidAutoContentHelper.videoTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getDiscoverVideos: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getTrendingMusic({int? limit}) async {
    if (youtubeExplodeRepository == null) return [];

    try {
      final trending = await youtubeExplodeRepository!.getTrending('Music');
      final result = trending.toList();
      return AndroidAutoContentHelper.videoTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getTrendingMusic: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getFavoriteVideos({int? limit}) async {
    try {
      final videos = await favoriteRepository!.favoriteVideos;
      final result = videos.reversed.toList();
      return AndroidAutoContentHelper.videoTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getFavoriteVideos: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getFavoriteChannels({int? limit}) async {
    try {
      final channels = await favoriteRepository!.favoriteChannels;
      final result = channels.reversed.toList();
      return AndroidAutoContentHelper.channelTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getFavoriteChannels: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getFavoritePlaylists({int? limit}) async {
    try {
      final playlists = await favoriteRepository!.favoritePlaylists;
      final result = playlists.reversed.toList();
      return AndroidAutoContentHelper.playlistTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getFavoritePlaylists: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getChannelVideos(String channelId) async {
    if (youtubeExplodeRepository == null) return [];

    try {
      final channelData = await youtubeExplodeRepository!.getChannel(channelId);
      final videos = channelData['videos'] as List<VideoTile>;
      return AndroidAutoContentHelper.videoTilesToMediaItems(videos.toList());
    } catch (e) {
      dev.log('Errore in _getChannelVideos: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getPlaylistVideos(String playlistId) async {
    if (youtubeExplodeRepository == null) return [];

    try {
      final playlistData =
          await youtubeExplodeRepository!.getPlaylist(playlistId);
      final videos = playlistData['videos'] as List<VideoTile>;
      return AndroidAutoContentHelper.videoTilesToMediaItems(videos.toList());
    } catch (e) {
      dev.log('Errore in _getPlaylistVideos: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getRecentSearches() async {
    try {
      final box = Hive.box('settings');
      if (box.containsKey('queryHistory')) {
        final history = jsonDecode(box.get('queryHistory')) as List<dynamic>;
        final queryHistory = history.map((e) => e.toString()).toList();

        return queryHistory
            .map((query) => MediaItem(
                  id: '${AndroidAutoContentHelper.searchResultsPrefix}$query',
                  title: query,
                  playable: false,
                  extras: const {
                    'browsable': true,
                    'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2,
                  },
                ))
            .toList();
      }
    } catch (e) {
      dev.log('Errore in _getRecentSearches: $e');
    }
    return [];
  }

  Future<List<MediaItem>> _getSearchResults(String query) async {
    if (youtubeExplodeRepository == null) return [];

    try {
      final result =
          await youtubeExplodeRepository!.searchContents(query: query);
      final items = result['items'] as List<dynamic>;
      final videos = items.whereType<VideoTile>().toList();
      return AndroidAutoContentHelper.videoTilesToMediaItems(videos);
    } catch (e) {
      dev.log('Errore in _getSearchResults: $e');
      return [];
    }
  }
}

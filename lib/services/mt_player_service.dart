import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:my_tube/providers/youtube_explode_provider.dart';
import 'package:my_tube/services/android_auto_detection_service.dart';
import 'package:my_tube/ui/views/video/widget/full_screen_video_view.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MtPlayerService extends BaseAudioHandler with QueueHandler, SeekHandler {
  MtPlayerService({required this.youtubeExplodeProvider});

  final YoutubeExplodeProvider youtubeExplodeProvider;
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
    // inizializza il media item da passare riprodurre
    final item = await _createMediaItem(id);

    // aggiungi il brano alla coda se non è già presente
    if (!playlist.contains(item)) {
      playlist.add(item);
    }

    currentIndex = playlist.indexOf(item);

    await _playCurrentTrack();
  }

  // Inizializza il player per la riproduzione di una coda di video
  Future<void> startPlayingPlaylist(List<String> ids) async {
    // inizializza la playlist ed il primo brano
    final list = await Future.wait(ids.map(_createMediaItem));

    for (final item in list) {
      // aggiungi il brano alla coda se non è già presente
      if (!playlist.contains(item)) {
        playlist.add(item);
      }
    }

    currentIndex = playlist.indexOf(list.first);

    await _playCurrentTrack();
  }

  // prepara lo stato del player per la riproduzione
  void _broadcastState() {
    try {
      bool isPlaying() =>
          chewieController != null &&
          chewieController!.videoPlayerController.value.isPlaying;

      AudioProcessingState audioProcessingState() {
        if (chewieController != null &&
            chewieController!.videoPlayerController.value.isInitialized) {
          return AudioProcessingState.ready;
        }
        return AudioProcessingState.idle;
      }

      // Protezione per Android Auto - evita errori quando il controller non è disponibile
      if (chewieController == null ||
          !chewieController!.videoPlayerController.value.isInitialized) {
        playbackState.add(playbackState.value.copyWith(
          processingState: AudioProcessingState.idle,
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
    try {
      currentTrack = playlist[currentIndex];

      if (chewieController != null && videoPlayerController != null) {
        await _disposeControllers();
      }

      // inizializza il video player controller da passare a chewie
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(currentTrack?.extras!['streamUrl']),
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
      );
      if (!videoPlayerController!.value.isInitialized) {
        await videoPlayerController!.initialize();
      }

      // inizializza il chewie controller per la riproduzione del video
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
    final item = await _createMediaItem(id);

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

  Future<void> addAllToQueue(List<String> ids) async {
    final list = await Future.wait(ids.map(_createMediaItem));

    int? firstAddedIndex;
    for (final item in list) {
      if (!playlist.contains(item)) {
        playlist.add(item);
        firstAddedIndex ??= playlist.length - 1;
      }
    }

    queue.add(playlist);

    if (currentIndex == -1 && firstAddedIndex != null) {
      currentIndex = firstAddedIndex;
      await _playCurrentTrack();
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

  Future<MediaItem> _createMediaItem(String id) async {
    final video = await youtubeExplodeProvider.getVideo(id);
    final manifest = await youtubeExplodeProvider.getVideoStreamManifest(id);
    final String muxedStream = manifest.muxed.isNotEmpty
        ? manifest.muxed.withHighestBitrate().url.toString()
        : manifest.audioOnly.withHighestBitrate().url.toString();

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

  Future<void> _disposeControllers() async {
    await chewieController?.videoPlayerController.dispose();
    chewieController?.dispose();
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
}

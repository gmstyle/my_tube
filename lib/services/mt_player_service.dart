import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/video_view/widget/full_screen_video_view.dart';
import 'package:video_player/video_player.dart';

class MtPlayerService extends BaseAudioHandler with QueueHandler, SeekHandler {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  int currentIndex = -1;
  MediaItem? currentTrack;
  List<MediaItem> playlist = [];
  bool get hasNextVideo => currentIndex < playlist.length - 1;
  bool get isShuffleModeEnabled =>
      playbackState.value.shuffleMode == AudioServiceShuffleMode.all;
  final playedIndexesInShuffleMode = <int>[];
  bool get hasNextVideoInShuffleMode =>
      playedIndexesInShuffleMode.length < playlist.length;

  // Stream per notificare il cambio di brano alla UI FullScreenView
  final StreamController<void> skipController =
      StreamController<void>.broadcast();
  Stream<void> get onSkip => skipController.stream;

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    playedIndexesInShuffleMode.clear();
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await _setRepeatMode(repeatMode);
  }

  @override
  Future<void> play() async {
    await chewieController.videoPlayerController.play();
  }

  @override
  Future<void> pause() async {
    await chewieController.videoPlayerController.pause();
  }

  @override
  Future<void> stop() async {
    await chewieController.videoPlayerController.pause();
    await chewieController.videoPlayerController.seekTo(Duration.zero);
  }

  @override
  Future<void> seek(Duration position) async {
    await chewieController.videoPlayerController.seekTo(position);
  }

  @override
  Future<void> skipToPrevious() async {
    if (currentIndex > 0) {
      currentIndex--;
      await chewieController.videoPlayerController.seekTo(Duration.zero);
      await _playCurrentTrack();
      skipController.add(null);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      await chewieController.videoPlayerController.seekTo(Duration.zero);
      await _playCurrentTrack();
      skipController.add(null);
    }
  }

  Future<void> skipToRandomIndex() async {
    //TODO: gestire il caso in cui è attivo lo shuffle ed è attivo il repeat all

    // se non ci sono altri brani da riprodurre, non fare nulla
    if (!hasNextVideoInShuffleMode) {
      return;
    }
    final random = Random();
    final randomIndex = random.nextInt(playlist.length);

    if (playedIndexesInShuffleMode.contains(randomIndex)) {
      // se l'indice è già stato riprodotto, riprova a generare un nuovo indice
      skipToRandomIndex();
    } else if (currentIndex != randomIndex) {
      currentIndex = randomIndex;
      playedIndexesInShuffleMode.add(currentIndex);
      await chewieController.videoPlayerController.seekTo(Duration.zero);
      await _playCurrentTrack();
      skipController.add(null);
    }
    developer.log(
        'skipToRandomIndex called: ${playedIndexesInShuffleMode.length}, current index: $currentIndex');
  }

  // Inizializza il player per la riproduzione singola
  Future<void> startPlaying(ResourceMT video) async {
    // inizializza il media item da passare riprodurre
    final item = _createMediaItem(video);

    // aggiungi il brano alla coda se non è già presente
    if (!playlist.contains(item)) {
      playlist.add(item);
    }

    currentIndex = playlist.indexOf(item);

    await _playCurrentTrack();
  }

  // Inizializza il player per la riproduzione di una coda di video
  Future<void> startPlayingPlaylist(List<ResourceMT> videos) async {
    // inizializza la playlist ed il primo brano
    final list = videos.map(_createMediaItem).toList();

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
    bool isPlaying() => chewieController.videoPlayerController.value.isPlaying;

    AudioProcessingState audioProcessingState() {
      if (chewieController.videoPlayerController.value.isInitialized) {
        return AudioProcessingState.ready;
      }
      return AudioProcessingState.idle;
    }

    playbackState.add(playbackState.value.copyWith(
        controls: [
          if (currentIndex > 0) MediaControl.skipToPrevious,
          if (playbackState.value.playing)
            MediaControl.pause
          else
            MediaControl.play,
          if (currentIndex < playlist.length - 1) MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [
          0,
          1,
          2
        ],
        processingState: audioProcessingState(),
        playing: isPlaying(),
        updatePosition: chewieController.videoPlayerController.value.position,
        speed: chewieController.videoPlayerController.value.playbackSpeed,
        queueIndex: currentIndex));
  }

  Future<void> _playCurrentTrack() async {
    currentTrack = playlist[currentIndex];

    // inizializza il video player controller da passare a chewie
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(currentTrack?.extras!['streamUrl']),
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );
    if (!videoPlayerController.value.isInitialized) {
      await videoPlayerController.initialize();
    }

    // inizializza il chewie controller per la riproduzione del video
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      showOptions: false,
      routePageBuilder: (context, animation, __, ___) {
        // uso un widget per il full screen personalizzato
        // per poter gestire il cambio di brano anche in full screen
        return FullScreenVideoView(
          mtPlayerService: this,
        );
      },
    );

    // aggiungi il brano alla coda
    queue.add(playlist);
    // aggiungi il brano al media item per la notifica
    mediaItem.add(currentTrack);

    // propaga lo stato del player ad audio_service e a tutti i listeners
    chewieController.videoPlayerController.addListener(_broadcastState);

    chewieController.videoPlayerController.addListener(() {
      // verifica che il video sia finito
      if (chewieController.videoPlayerController.value.duration ==
          chewieController.videoPlayerController.value.position) {
        // verifica che ci siano altri brani nella coda
        if (isShuffleModeEnabled) {
          if (hasNextVideoInShuffleMode) {
            skipToRandomIndex();
          } else {
            stop();
          }
        } else {
          if (hasNextVideo) {
            skipToNext();
          } else {
            stop();
          }
        }
      }
    });
  }

  Future<void> _setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (repeatMode == AudioServiceRepeatMode.none) {
      await chewieController.videoPlayerController.setLooping(false);
    } else {
      await chewieController.videoPlayerController.setLooping(true);
    }
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  Future<void> addToQueue(ResourceMT video) async {
    final item = _createMediaItem(video);

    // aggiungi il brano alla coda se non è già presente
    if (!playlist.contains(item)) {
      playlist.add(item);
      queue.add(playlist);

      if (currentIndex == -1) {
        currentIndex = playlist.indexOf(item);
        await _playCurrentTrack();
      }
    }
  }

  Future<bool?> removeFromQueue(String id) async {
    final index = playlist.indexWhere((element) => element.id == id);

    if (index == -1) {
      return null;
    }

    var currentTrackBeforeRemoval = currentTrack;

    if (index < currentIndex) {
      currentIndex--;
    } else if (index == currentIndex) {
      playlist.removeAt(index);
      queue.add(playlist);

      if (playlist.isNotEmpty) {
        currentIndex = index < playlist.length ? index : playlist.length - 1;
        await chewieController.videoPlayerController.seekTo(Duration.zero);
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
      currentIndex = playlist.indexOf(currentTrackBeforeRemoval!);
    }

    playlist.removeAt(index);
    queue.add(playlist);

    return true;
  }

  Future<void> stopPlayingAndClearQueue() async {
    await stopPlayingAndClearMediaItem();
    playlist.clear();
    queue.value.clear();
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

  MediaItem _createMediaItem(ResourceMT video) {
    return MediaItem(
        id: video.id!,
        title: video.title!,
        album: video.channelTitle!,
        artUri: Uri.parse(video.thumbnailUrl!),
        duration: Duration(milliseconds: video.duration!),
        extras: {
          'streamUrl': video.streamUrl!,
          'description': video.description,
        });
  }
}

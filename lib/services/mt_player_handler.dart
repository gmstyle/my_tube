import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/song_view/widget/full_screen_video_view.dart';
import 'package:video_player/video_player.dart';

class MtPlayerHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  int currentIndex = 0;
  late MediaItem currentTrack;
  List<MediaItem> playlist = [];
  bool get hasNextVideo => currentIndex < playlist.length - 1;

  // Stream per notificare il cambio di brano
  final StreamController<void> skipController =
      StreamController<void>.broadcast();
  Stream<void> get onSkip => skipController.stream;

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) {
    return chewieController.videoPlayerController
        .setLooping(repeatMode == AudioServiceRepeatMode.one);
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
      await _playCurrentTrack();
      await chewieController.videoPlayerController.seekTo(Duration.zero);
      skipController.add(null);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      await _playCurrentTrack();
      await chewieController.videoPlayerController.seekTo(Duration.zero);
      skipController.add(null);
    }
  }

  // Inizializza il player per la riproduzione singola
  Future<void> startPlaying(ResourceMT video) async {
    // inizializza il media item da passare riprodurre
    final item = MediaItem(
        id: video.id!,
        title: video.title!,
        album: video.channelTitle!,
        artUri: Uri.parse(video.thumbnailUrl!),
        duration: Duration(milliseconds: video.duration!),
        extras: {
          'streamUrl': video.streamUrl!,
          'description': video.description,
        });

    // aggiungi il brano alla coda se non è già presente
    if (!playlist.contains(item)) {
      playlist.add(item);
    }

    currentIndex = playlist.indexOf(item);

    await _playCurrentTrack();
  }

  Future<void> _playCurrentTrack() async {
    currentTrack = playlist[currentIndex];

    // inizializza il video player controller da passare a chewie
    videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(currentTrack.extras!['streamUrl']),
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
    await videoPlayerController.initialize();

    // inizializza il chewie controller per la riproduzione del video
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      showOptions: false,
      routePageBuilder: (context, animation, __, ___) {
        // uso un widget per il full screen personalizzato
        // per poter gestire il cambio di brano anche in full screen
        return FullScreenVideoView(
          mtPlayerHandler: this,
        );
      },
    );

    // aggiungi il brano alla coda
    queue.add(playlist);
    // aggiungi il brano al media item per la notifica
    mediaItem.add(currentTrack);

    // propaga lo stato del player ad audio_service e a tutti i listeners
    chewieController.videoPlayerController.addListener(broadcastState);

    chewieController.videoPlayerController.addListener(() {
      // verifica che il video sia finito
      if (chewieController.videoPlayerController.value.duration ==
          chewieController.videoPlayerController.value.position) {
        // verifica che ci siano altri brani nella coda
        if (hasNextVideo) {
          skipToNext();
        } else {
          stop();
        }
      }
    });
  }

  // Inizializza il player per la riproduzione di una coda di video
  Future<void> startPlayingPlaylist(List<ResourceMT> videos) async {
    // inizializza la playlist ed il primo brano
    final list = videos
        .map((video) => MediaItem(
                id: video.id!,
                title: video.title!,
                album: video.channelTitle!,
                artUri: Uri.parse(video.thumbnailUrl!),
                duration: Duration(milliseconds: video.duration!),
                extras: {
                  'streamUrl': video.streamUrl!,
                }))
        .toList();

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
  void broadcastState() {
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
}

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:video_player/video_player.dart';

class MtPlayerHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  int currentIndex = 0;
  late MediaItem currentTrack;
  List<MediaItem> playlist = [];

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
  Future<void> skipToNext() async {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      await _playCurrentTrack();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (currentIndex > 0) {
      currentIndex--;

      await _playCurrentTrack();
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
        });
    mediaItem.add(item);

    // inizializza il video player controller da passare a chewie
    videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(item.extras!['streamUrl']),
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
    await videoPlayerController.initialize();

    // inizializza il chewie controller per la riproduzione del video
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
    );

    // propaga lo stato del player ad audio_service e a tutti i listeners
    chewieController.videoPlayerController.addListener(broadcastState);
  }

  // Inizializza il player per la riproduzione di una coda di video
  Future<void> startPlayingPlaylist(List<ResourceMT> videos) async {
    // inizializza la playlist ed il primo brano
    playlist = videos
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

    currentIndex = 0;

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
    );

    final item = MediaItem(
        id: currentTrack.id,
        title: currentTrack.title,
        album: currentTrack.album,
        artUri: currentTrack.artUri,
        duration: currentTrack.duration,
        extras: currentTrack.extras);

    // aggiungi il brano alla coda
    mediaItem.add(item);

    // propaga lo stato del player ad audio_service e a tutti i listeners
    chewieController.videoPlayerController.addListener(broadcastState);

    // passa al brano successivo quando il video è finito fino a che non ci sono più brani
    chewieController.videoPlayerController.addListener(() {
      // verifica che il video sia finito
      if (chewieController.videoPlayerController.value.duration ==
          chewieController.videoPlayerController.value.position) {
        // verifica che ci siano altri brani nella coda
        if (currentIndex < playlist.length - 1) {
          skipToNext();
        } else {
          currentIndex = 0;
          stop();
        }
      }
    });
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
      androidCompactActionIndices: const [0, 1, 2],
      processingState: audioProcessingState(),
      playing: isPlaying(),
      updatePosition: chewieController.videoPlayerController.value.position,
      speed: chewieController.videoPlayerController.value.playbackSpeed,
    ));
  }
}

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:video_player/video_player.dart';

class MtPlayerHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  @override
  Future<void> play() async {
    await chewieController.play();
  }

  @override
  Future<void> pause() async {
    await chewieController.pause();
  }

  @override
  Future<void> stop() async {
    await chewieController.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await chewieController.seekTo(position);
  }

  Future<void> startPlaying(ResourceMT video) async {
    // inizializza il video player controller da passare a chewie
    videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(video.streamUrl!),
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
    await videoPlayerController.initialize();

    // inizializza il chewie controller per la riproduzione del video
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
    );

    // inizializza la coda di riproduzione
    final item = MediaItem(
        id: video.id!,
        title: video.title!,
        album: video.channelTitle!,
        artUri: Uri.parse(video.thumbnailUrl!),
        duration: Duration(milliseconds: video.duration!));
    mediaItem.add(item);

    // propaga lo stato del player ad audio_service e a tutti i listeners
    chewieController.videoPlayerController.addListener(broadcastState);
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
        MediaControl.skipToPrevious,
        if (playbackState.value.playing)
          MediaControl.pause
        else
          MediaControl.play,
        MediaControl.skipToNext,
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

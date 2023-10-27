import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/utils/utils.dart';

class MtPlayerHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  late StreamController<PlaybackState> streamController;

  Function? _videoPlay;
  Function? _videoPause;
  Function? _videoStop;
  Function? _videoSeek;

  @override
  Future<void> play() {
    return _videoPlay!();
  }

  @override
  Future<void> pause() {
    return _videoPause!();
  }

  @override
  Future<void> stop() {
    return _videoStop!();
  }

  @override
  Future<void> seek(Duration position) {
    return _videoSeek!(position);
  }

  void setMediaItem(ResourceMT video) {
    final item = MediaItem(
        id: video.id!,
        title: video.title!,
        album: video.channelTitle!,
        artUri: Uri.parse(video.thumbnailUrl!),
        duration: Duration(milliseconds: video.duration!));
    mediaItem.add(item);
  }

  void setVideoFunctions(Function videoPlay, Function videoPause,
      Function videoStop, Function seek) {
    _videoPlay = videoPlay;
    _videoPause = videoPause;
    _videoStop = videoStop;
    _videoSeek = seek;
  }

  void initializeStreamController(ChewieController chewieController) {
    bool isPlaying() => chewieController.videoPlayerController.value.isPlaying;

    AudioProcessingState audioProcessingState() {
      if (chewieController.videoPlayerController.value.isInitialized) {
        return AudioProcessingState.ready;
      }
      return AudioProcessingState.idle;
    }

    Duration bufferedPosition() {
      final cachedValue = chewieController.videoPlayerController.value;
      if (cachedValue.isInitialized) {
        return cachedValue.buffered.isEmpty
            ? Duration.zero
            : cachedValue.buffered.last.end;
      }
      return Duration.zero;
    }

    void addVideoEvent() {
      streamController.add(PlaybackState(
          controls: [
            MediaControl.rewind,
            if (isPlaying()) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.fastForward
          ],
          systemActions: {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward
          },
          androidCompactActionIndices: [
            0,
            1,
            3
          ],
          processingState: audioProcessingState(),
          playing: isPlaying(),
          updatePosition: chewieController.videoPlayerController.value.position,
          bufferedPosition: bufferedPosition(),
          speed: chewieController.videoPlayerController.value.playbackSpeed));
    }

    void startStream() {
      chewieController.videoPlayerController.addListener(addVideoEvent);
    }

    void stopStream() {
      chewieController.videoPlayerController.removeListener(addVideoEvent);
      streamController.close();
    }

    streamController = StreamController<PlaybackState>(
        onListen: startStream,
        onPause: stopStream,
        onResume: startStream,
        onCancel: stopStream);
  }
}

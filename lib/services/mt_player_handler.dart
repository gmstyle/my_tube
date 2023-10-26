import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

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

  void setVideoFunctions(Function videoPlay, Function videoPause,
      Function videoStop, Function seek, MediaItem item) {
    _videoPlay = videoPlay;
    _videoPause = videoPause;
    _videoStop = videoStop;
    _videoSeek = seek;
    mediaItem.add(item);
  }

  void initializeStreamController(ChewieController chewieController) {
    bool _isPlaying() => chewieController.videoPlayerController.value.isPlaying;

    AudioProcessingState _audioProcessingState() {
      if (chewieController.videoPlayerController.value.isInitialized) {
        return AudioProcessingState.ready;
      }
      return AudioProcessingState.idle;
    }

    Duration _bufferedPosition() {
      DurationRange? currentBufferedRange = chewieController
          .videoPlayerController.value.buffered
          .firstWhere((durationRange) {
        Duration position =
            chewieController.videoPlayerController.value.position;
        bool isCurrentBufferedRange =
            durationRange.start < position && durationRange.end > position;
        return isCurrentBufferedRange;
      });
      if (currentBufferedRange == null) {
        return Duration.zero;
      }
      return currentBufferedRange.end;
    }

    void _addVideoEvent() {
      streamController.add(PlaybackState(
          controls: [
            MediaControl.rewind,
            if (_isPlaying()) MediaControl.pause else MediaControl.play,
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
          processingState: _audioProcessingState(),
          playing: _isPlaying(),
          updatePosition: chewieController.videoPlayerController.value.position,
          bufferedPosition: _bufferedPosition(),
          speed: chewieController.videoPlayerController.value.playbackSpeed));
    }

    void startStream() {
      chewieController.videoPlayerController.addListener(_addVideoEvent);
    }

    void stopStream() {
      chewieController.videoPlayerController.removeListener(_addVideoEvent);
      streamController.close();
    }

    streamController = StreamController<PlaybackState>(
        onListen: startStream,
        onPause: stopStream,
        onResume: startStream,
        onCancel: stopStream);
  }
}

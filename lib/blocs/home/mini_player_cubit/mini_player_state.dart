part of 'mini_player_cubit.dart';

enum MiniPlayerStatus { hidden, shown, loading }

class MiniPlayerState extends Equatable {
  const MiniPlayerState._(
      {required this.status, this.streamUrl, this.video, this.flickManager});

  final MiniPlayerStatus status;
  final String? streamUrl;
  final VideoMT? video;
  final ChewieController? flickManager;

  const MiniPlayerState.loading() : this._(status: MiniPlayerStatus.loading);
  const MiniPlayerState.hidden() : this._(status: MiniPlayerStatus.hidden);
  const MiniPlayerState.shown(
      String streamUrl, VideoMT video, ChewieController flickManager)
      : this._(
            status: MiniPlayerStatus.shown,
            streamUrl: streamUrl,
            video: video,
            flickManager: flickManager);

  @override
  List<Object?> get props => [status, streamUrl];
}

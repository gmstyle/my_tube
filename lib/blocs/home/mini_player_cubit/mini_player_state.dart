part of 'mini_player_cubit.dart';

enum MiniPlayerStatus { hidden, shown, loading }

class MiniPlayerState extends Equatable {
  const MiniPlayerState._(
      {required this.status,
      this.streamUrl,
      this.video,
      this.chewieController,
      this.mtPlayerHandler});

  final MiniPlayerStatus status;
  final String? streamUrl;
  final VideoMT? video;
  final ChewieController? chewieController;
  final MtPlayerHandler? mtPlayerHandler;

  const MiniPlayerState.loading() : this._(status: MiniPlayerStatus.loading);
  const MiniPlayerState.hidden() : this._(status: MiniPlayerStatus.hidden);
  const MiniPlayerState.shown(String streamUrl, VideoMT video,
      ChewieController chewieController, MtPlayerHandler mtPlayerHandler)
      : this._(
            status: MiniPlayerStatus.shown,
            streamUrl: streamUrl,
            video: video,
            chewieController: chewieController,
            mtPlayerHandler: mtPlayerHandler);

  @override
  List<Object?> get props => [status, streamUrl];
}

part of 'mini_player_cubit.dart';

enum MiniPlayerStatus { hidden, shown, loading }

class MiniPlayerState extends Equatable {
  const MiniPlayerState._(
      {required this.status, this.video, this.mtPlayerHandler});

  final MiniPlayerStatus status;

  final ResourceMT? video;

  final MtPlayerHandler? mtPlayerHandler;

  const MiniPlayerState.loading() : this._(status: MiniPlayerStatus.loading);
  const MiniPlayerState.hidden() : this._(status: MiniPlayerStatus.hidden);
  const MiniPlayerState.shown(ResourceMT video, MtPlayerHandler mtPlayerHandler)
      : this._(
            status: MiniPlayerStatus.shown,
            video: video,
            mtPlayerHandler: mtPlayerHandler);

  @override
  List<Object?> get props => [status];
}

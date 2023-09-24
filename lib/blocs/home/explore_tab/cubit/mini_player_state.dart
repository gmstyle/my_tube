part of 'mini_player_cubit.dart';

enum MiniPlayerStatus { hidden, shown }

class MiniPlayerState extends Equatable {
  const MiniPlayerState._({required this.status, this.streamUrl, this.video});

  final MiniPlayerStatus status;
  final String? streamUrl;
  final Video? video;

  const MiniPlayerState.hidden() : this._(status: MiniPlayerStatus.hidden);
  const MiniPlayerState.shown(String streamUrl, Video video)
      : this._(
            status: MiniPlayerStatus.shown, streamUrl: streamUrl, video: video);

  @override
  List<Object?> get props => [status, streamUrl];
}

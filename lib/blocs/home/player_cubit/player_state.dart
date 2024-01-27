part of 'player_cubit.dart';

enum PlayerStatus { hidden, shown, loading }

class PlayerState extends Equatable {
  const PlayerState._({required this.status, this.video});

  final PlayerStatus status;

  final ResourceMT? video;

  const PlayerState.loading() : this._(status: PlayerStatus.loading);
  const PlayerState.hidden() : this._(status: PlayerStatus.hidden);
  const PlayerState.shown()
      : this._(
          status: PlayerStatus.shown,
        );

  @override
  List<Object?> get props => [status, video];
}

part of 'player_cubit.dart';

enum PlayerStatus { hidden, shown, loading, error }

class PlayerState extends Equatable {
  const PlayerState._({required this.status, this.video, this.message});

  final PlayerStatus status;

  final Video? video;
  final String? message;

  const PlayerState.loading() : this._(status: PlayerStatus.loading);
  const PlayerState.hidden() : this._(status: PlayerStatus.hidden);
  const PlayerState.shown()
      : this._(
          status: PlayerStatus.shown,
        );
  const PlayerState.error(String message)
      : this._(status: PlayerStatus.error, message: message);

  @override
  List<Object?> get props => [status, video, message];
}

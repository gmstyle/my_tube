part of 'player_cubit.dart';

enum PlayerStatus { hidden, shown, loading, error }

enum LoadingOperation { play, addToQueue, none }

class PlayerState extends Equatable {
  const PlayerState._({
    required this.status,
    this.video,
    this.message,
    this.loadingProgress,
    this.loadingTotal,
    this.loadingOperation = LoadingOperation.none,
  });

  final PlayerStatus status;

  final Video? video;
  final String? message;
  final int? loadingProgress;
  final int? loadingTotal;
  final LoadingOperation loadingOperation;

  const PlayerState.loading(
      {LoadingOperation operation = LoadingOperation.none})
      : this._(
          status: PlayerStatus.loading,
          loadingOperation: operation,
        );

  const PlayerState.loadingWithProgress({
    required int current,
    required int total,
    LoadingOperation operation = LoadingOperation.none,
  }) : this._(
          status: PlayerStatus.loading,
          loadingProgress: current,
          loadingTotal: total,
          loadingOperation: operation,
        );

  const PlayerState.hidden() : this._(status: PlayerStatus.hidden);

  const PlayerState.shown()
      : this._(
          status: PlayerStatus.shown,
        );

  const PlayerState.error(String message)
      : this._(status: PlayerStatus.error, message: message);

  @override
  List<Object?> get props =>
      [status, video, message, loadingProgress, loadingTotal, loadingOperation];
}

part of 'mini_player_cubit.dart';

sealed class MiniPlayerState extends Equatable {
  const MiniPlayerState();
}

final class ShowMiniPlayer extends MiniPlayerState {
  final Video video;

  const ShowMiniPlayer(this.video);

  @override
  List<Object> get props => [video];
}

final class HideMiniPlayer extends MiniPlayerState {
  const HideMiniPlayer();

  @override
  List<Object> get props => [];
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:googleapis/youtube/v3.dart';

part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  MiniPlayerCubit() : super(const MiniPlayerState.hidden());

  void showMiniPlayer(Video video) {
    emit(MiniPlayerState.shown(video));
  }

  void hideMiniPlayer() {
    emit(const MiniPlayerState.hidden());
  }
}

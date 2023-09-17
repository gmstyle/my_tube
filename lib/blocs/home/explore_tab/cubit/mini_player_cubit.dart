import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  MiniPlayerCubit() : super(const HideMiniPlayer());

  void showMiniPlayer(Video video) {
    emit(ShowMiniPlayer(video));
  }

  void hideMiniPlayer() {
    emit(const HideMiniPlayer());
  }
}

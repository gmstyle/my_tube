import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/respositories/youtube_repository.dart';

part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final YoutubeRepository youtubeRepository;
  MiniPlayerCubit({required this.youtubeRepository})
      : super(const MiniPlayerState.hidden());

  Future<void> showMiniPlayer(Video video) async {
    final streamUrl = await youtubeRepository.getStreamUrl(video.id!);

    emit(MiniPlayerState.shown(streamUrl, video));
  }

  void hideMiniPlayer() {
    emit(const MiniPlayerState.hidden());
  }
}

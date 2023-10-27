import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:video_player/video_player.dart';

part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final YoutubeRepository youtubeRepository;
  final MtPlayerHandler mtPlayerHandler;
  MiniPlayerCubit(
      {required this.youtubeRepository, required this.mtPlayerHandler})
      : super(const MiniPlayerState.hidden());

  Future<void> showMiniPlayer(String videoId) async {
    emit(const MiniPlayerState.loading());

    final streamUrl = await youtubeRepository.getStreamUrl(videoId);
    final response = await youtubeRepository.getVideos(videoId: videoId);
    final videoWithStreamUrl =
        response.resources.first.copyWith(streamUrl: streamUrl);
    await initPlayer(videoWithStreamUrl);
    emit(MiniPlayerState.shown(streamUrl, videoWithStreamUrl,
        mtPlayerHandler.chewieController, mtPlayerHandler));
  }

  void hideMiniPlayer() {
    mtPlayerHandler.chewieController.dispose();
    mtPlayerHandler.videoPlayerController.dispose();
    mtPlayerHandler.videoPlayerController
        .removeListener(mtPlayerHandler.broadcastState);
    emit(const MiniPlayerState.hidden());
  }

  void pauseMiniPlayer() {
    mtPlayerHandler.chewieController.pause();
  }

  void playMiniPlayer() {
    mtPlayerHandler.chewieController.play();
  }

  Future<void> initPlayer(ResourceMT video) async {
    await mtPlayerHandler.startPlaying(video);
  }
}

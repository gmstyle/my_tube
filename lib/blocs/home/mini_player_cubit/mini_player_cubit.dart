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

  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  Future<void> showMiniPlayer(String videoId) async {
    emit(const MiniPlayerState.loading());

    final streamUrl = await youtubeRepository.getStreamUrl(videoId);
    final response = await youtubeRepository.getVideos(videoId: videoId);
    final videoWithStreamUrl =
        response.resources.first.copyWith(streamUrl: streamUrl);
    await initPlayer(videoWithStreamUrl);
    emit(MiniPlayerState.shown(
        streamUrl, videoWithStreamUrl, chewieController, mtPlayerHandler));
  }

  void hideMiniPlayer() {
    mtPlayerHandler.streamController.close();
    videoPlayerController.dispose();
    chewieController.dispose();
    emit(const MiniPlayerState.hidden());
  }

  void pauseMiniPlayer() {
    chewieController.pause();
  }

  void playMiniPlayer() {
    chewieController.play();
  }

  Future<void> initPlayer(ResourceMT video) async {
    videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(video.streamUrl!),
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
    );
    mtPlayerHandler.setVideoFunctions(
        chewieController.play, chewieController.pause, chewieController.seekTo,
        () {
      chewieController.seekTo(Duration.zero);
      chewieController.pause();
    });
    mtPlayerHandler.setMediaItem(video);
    mtPlayerHandler.initializeStreamController(chewieController);
    mtPlayerHandler.playbackState
        .addStream(mtPlayerHandler.streamController.stream);
  }
}

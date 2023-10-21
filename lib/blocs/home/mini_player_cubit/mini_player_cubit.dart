import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:video_player/video_player.dart';

part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final YoutubeRepository youtubeRepository;
  MiniPlayerCubit({required this.youtubeRepository})
      : super(const MiniPlayerState.hidden());

  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  Future<void> showMiniPlayer(VideoMT? video) async {
    emit(const MiniPlayerState.loading());

    if (video != null) {
      final streamUrl = await youtubeRepository.getStreamUrl(video.id!);
      final videoWithStreamUrl = video.copyWith(streamUrl: streamUrl);
      await initPlayer(streamUrl);
      emit(MiniPlayerState.shown(
          streamUrl, videoWithStreamUrl, chewieController));
    }
  }

  void hideMiniPlayer() {
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

  Future<void> initPlayer(String streamUrl) async {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(streamUrl));
    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
    );
  }
}

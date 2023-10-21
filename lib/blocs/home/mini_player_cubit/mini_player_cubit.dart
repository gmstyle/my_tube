import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:video_player/video_player.dart';

part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final YoutubeRepository youtubeRepository;
  MiniPlayerCubit({required this.youtubeRepository})
      : super(const MiniPlayerState.hidden());

  late VideoPlayerController videoPlayerController;
  late FlickManager flickManager;

  Future<void> showMiniPlayer(VideoMT? video) async {
    emit(const MiniPlayerState.loading());

    if (video != null) {
      final streamUrl = await youtubeRepository.getStreamUrl(video.id!);
      final videoWithStreamUrl = video.copyWith(streamUrl: streamUrl);
      await initPlayer(streamUrl);
      playMiniPlayer();
      emit(MiniPlayerState.shown(streamUrl, videoWithStreamUrl, flickManager));
    }
  }

  void hideMiniPlayer() {
    videoPlayerController.dispose();
    flickManager.dispose();
    emit(const MiniPlayerState.hidden());
  }

  void pauseMiniPlayer() {
    flickManager.flickControlManager?.pause();
  }

  void playMiniPlayer() {
    flickManager.flickControlManager?.play();
  }

  Future<void> initPlayer(String streamUrl) async {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(streamUrl));
    await videoPlayerController.initialize();

    flickManager = FlickManager(
        videoPlayerController: videoPlayerController,
        onVideoEnd: () {
          //TODO: implementare la riproduzione del video successivo
        });
  }
}

import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:equatable/equatable.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:video_player/video_player.dart';

part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final YoutubeRepository youtubeRepository;
  MiniPlayerCubit({required this.youtubeRepository})
      : super(const MiniPlayerState.hidden());

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  Future<void> showMiniPlayer(Video? video, SearchResult? result) async {
    emit(const MiniPlayerState.loading());

    if (video != null) {
      final streamUrl = await youtubeRepository.getStreamUrl(video.id!);
      await initPlayer(streamUrl);
      emit(MiniPlayerState.shown(streamUrl, video, null, chewieController!));
    }

    if (result != null) {
      final streamUrl =
          await youtubeRepository.getStreamUrl(result.id!.videoId!);
      await initPlayer(streamUrl);
      emit(MiniPlayerState.shown(streamUrl, null, result, chewieController!));
    }
  }

  void hideMiniPlayer() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    emit(const MiniPlayerState.hidden());
  }

  void pauseMiniPlayer() {
    videoPlayerController?.pause();
  }

  void playMiniPlayer() {
    videoPlayerController?.play();
  }

  Future<void> initPlayer(String streamUrl) async {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(streamUrl));
    await videoPlayerController!.initialize();
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      hideControlsTimer: const Duration(seconds: 1),
      /* additionalOptions: (context) {
        return [OptionItem(onTap: () {}, iconData: Icons.abc, title: 'Prova')];
      }, */
    );
  }
}

import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/services/mt_player_handler.dart';

part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final YoutubeRepository youtubeRepository;
  final MtPlayerHandler mtPlayerHandler;
  MiniPlayerCubit(
      {required this.youtubeRepository, required this.mtPlayerHandler})
      : super(const MiniPlayerState.hidden());

  Future<void> startPlaying(String videoId) async {
    emit(const MiniPlayerState.loading());

    final streamUrl = await youtubeRepository.getStreamUrl(videoId);
    final response = await youtubeRepository.getVideos(videoIds: [videoId]);
    final videoWithStreamUrl =
        response.resources.first.copyWith(streamUrl: streamUrl);
    await _startPlayingVideo(videoWithStreamUrl);
    emit(MiniPlayerState.shown(videoWithStreamUrl, mtPlayerHandler));
  }

  Future<void> startPlayingPlaylist(List<String> videoIds) async {
    emit(const MiniPlayerState.loading());

    final response = await youtubeRepository.getVideos(videoIds: videoIds);
    final videosWithStreamUrl = <ResourceMT>[];
    for (ResourceMT video in response.resources) {
      final streamUrl = await youtubeRepository.getStreamUrl(video.id!);
      videosWithStreamUrl.add(video.copyWith(streamUrl: streamUrl));
    }
    await _startPlayingPlaylist(videosWithStreamUrl);
    emit(MiniPlayerState.shown(videosWithStreamUrl.first, mtPlayerHandler));
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

  Future<void> _startPlayingVideo(ResourceMT video) async {
    await mtPlayerHandler.startPlaying(video);
  }

  Future<void> _startPlayingPlaylist(List<ResourceMT> videos) async {
    await mtPlayerHandler.startPlayingQueue(videos);
  }
}

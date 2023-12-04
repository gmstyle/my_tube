import 'package:bloc/bloc.dart';
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

    final response = await youtubeRepository.getVideos(videoIds: [videoId]);

    await _startPlaying(response.resources.first);

    emit(const MiniPlayerState.shown());

    mtPlayerHandler.queue.listen((value) {
      if (value.isEmpty) {
        emit(const MiniPlayerState.hidden());
      }
    });
  }

  Future<void> startPlayingPlaylist(List<String> videoIds) async {
    emit(const MiniPlayerState.loading());

    final response = await youtubeRepository.getVideos(videoIds: videoIds);

    await _startPlayingPlaylist(response.resources);

    emit(const MiniPlayerState.shown());
  }

  /* Future<void> showMiniPlayer() async {
    emit(const MiniPlayerState.shown());
  }

  void hideMiniPlayer() {
    emit(const MiniPlayerState.hidden());
  } */

  Future<void> _startPlaying(ResourceMT video) async {
    await mtPlayerHandler.startPlaying(video);
  }

  Future<void> _startPlayingPlaylist(List<ResourceMT> videos) async {
    await mtPlayerHandler.startPlayingPlaylist(videos);
  }
}

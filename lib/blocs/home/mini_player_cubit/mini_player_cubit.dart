import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/services/mt_player_handler.dart';

part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final InnertubeRepository innertubeRepository;

  final MtPlayerHandler mtPlayerHandler;

  MiniPlayerCubit(
      {required this.innertubeRepository, required this.mtPlayerHandler})
      : super(const MiniPlayerState.hidden());

  init() {
    mtPlayerHandler.queue.listen((value) {
      if (value.isEmpty) {
        emit(const MiniPlayerState.hidden());
      }
    });
  }

  Future<void> startPlaying(String id) async {
    emit(const MiniPlayerState.loading());

    final response = await innertubeRepository.getVideo(id);

    await _startPlaying(response);

    emit(const MiniPlayerState.shown());
  }

  Future<void> startPlayingPlaylist(List<ResourceMT> videos) async {
    emit(const MiniPlayerState.loading());

    //final response = await youtubeRepository.getVideos(videoIds: videoIds);

    await _startPlayingPlaylist(videos);

    emit(const MiniPlayerState.shown());
  }

  Future<void> skipToNext() async {
    emit(const MiniPlayerState.loading());
    await mtPlayerHandler.skipToNext();
    emit(const MiniPlayerState.shown());
  }

  Future<void> skipToPrevious() async {
    emit(const MiniPlayerState.loading());
    await mtPlayerHandler.skipToPrevious();
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

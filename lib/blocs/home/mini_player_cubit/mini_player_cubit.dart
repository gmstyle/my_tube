import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/services/mt_player_service.dart';

part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final InnertubeRepository innertubeRepository;

  final MtPlayerService mtPlayerService;

  MiniPlayerCubit(
      {required this.innertubeRepository, required this.mtPlayerService})
      : super(const MiniPlayerState.hidden());

  init() {
    mtPlayerService.queue.listen((value) {
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
    // se lo streamUrl è null, vuol dire arrivo da una channel page
    // e cioè dal pulsante play all di una section i video
    if (videos.first.streamUrl == null) {
      final futures = videos.map((e) => innertubeRepository.getVideo(e.id!));
      videos = await Future.wait(futures);
    }
    await _startPlayingPlaylist(videos);

    emit(const MiniPlayerState.shown());
  }

  Future<void> skipToNext() async {
    emit(const MiniPlayerState.loading());
    await mtPlayerService.skipToNext();
    emit(const MiniPlayerState.shown());
  }

  Future<void> skipToPrevious() async {
    emit(const MiniPlayerState.loading());
    await mtPlayerService.skipToPrevious();
    emit(const MiniPlayerState.shown());
  }

  Future<void> _startPlaying(ResourceMT video) async {
    await mtPlayerService.startPlaying(video);
  }

  Future<void> _startPlayingPlaylist(List<ResourceMT> videos) async {
    await mtPlayerService.startPlayingPlaylist(videos);
  }

  Future<void> addToQueue(String id) async {
    final video = await innertubeRepository.getVideo(id);
    await mtPlayerService.addToQueue(video);
    emit(const MiniPlayerState.shown());
  }

  Future<void> removeFromQueue(ResourceMT video) async {
    final result = await mtPlayerService.removeFromQueue(video);
    if (result != null && result) {
      emit(const MiniPlayerState.shown());
    } else if (result != null && !result) {
      emit(const MiniPlayerState.hidden());
    }
  }

  Future<void> stopPlayingAndClearMediaItem() async {
    emit(const MiniPlayerState.loading());
    await mtPlayerService.stopPlayingAndClearMediaItem();
    emit(const MiniPlayerState.hidden());
  }
}

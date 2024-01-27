import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/services/mt_player_service.dart';

part 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final InnertubeRepository innertubeRepository;

  final MtPlayerService mtPlayerService;

  PlayerCubit(
      {required this.innertubeRepository, required this.mtPlayerService})
      : super(const PlayerState.hidden());

  init() {
    mtPlayerService.queue.listen((value) {
      if (value.isEmpty) {
        emit(const PlayerState.hidden());
      }
    });
  }

  Future<void> startPlaying(String id) async {
    emit(const PlayerState.loading());

    final response = await innertubeRepository.getVideo(id);

    await _startPlaying(response);

    emit(const PlayerState.shown());
  }

  Future<void> startPlayingPlaylist(List<ResourceMT> videos,
      {bool renewStreamUrls = false}) async {
    emit(const PlayerState.loading());
    // svuoto la coda
    await mtPlayerService.clearQueue();
    // se lo streamUrl è null, vuol dire arrivo da una channel page
    // e cioè dal pulsante play all di una section i video
    if (videos.first.streamUrl == null || renewStreamUrls) {
      final futures = videos.map((e) => innertubeRepository.getVideo(e.id!));
      videos = await Future.wait(futures);
    }
    await _startPlayingPlaylist(videos);

    emit(const PlayerState.shown());
  }

  Future<void> skipToNext() async {
    emit(const PlayerState.loading());
    await mtPlayerService.skipToNext();
    emit(const PlayerState.shown());
  }

  Future<void> skipToNextInShuffleMode() async {
    emit(const PlayerState.loading());
    await mtPlayerService.skipToNextInShuffleMode();
    emit(const PlayerState.shown());
  }

  Future<void> skipToPrevious() async {
    emit(const PlayerState.loading());
    await mtPlayerService.skipToPrevious();
    emit(const PlayerState.shown());
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
    emit(const PlayerState.shown());
  }

  Future<void> addAllToQueue(List<ResourceMT> videos) async {
    final futures = videos.map((e) => innertubeRepository.getVideo(e.id!));
    videos = await Future.wait(futures);
    await mtPlayerService.addAllToQueue(videos);
    emit(const PlayerState.shown());
  }

  Future<bool?> removeFromQueue(String id) async {
    final result = await mtPlayerService.removeFromQueue(id);
    if (result != null && result) {
      emit(const PlayerState.shown());
    } else if (result != null && !result) {
      emit(const PlayerState.hidden());
    }

    return result;
  }

  Future<void> stopPlayingAndClearMediaItem() async {
    emit(const PlayerState.loading());
    await mtPlayerService.stopPlayingAndClearMediaItem();
    emit(const PlayerState.hidden());
  }

  Future<void> stopPlayingAndClearQueue() async {
    emit(const PlayerState.loading());
    await mtPlayerService.stopPlayingAndClearQueue();
    emit(const PlayerState.hidden());
  }
}

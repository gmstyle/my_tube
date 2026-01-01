import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final YoutubeExplodeRepository youtubeExplodeRepository;

  final MtPlayerService mtPlayerService;

  PlayerCubit(
      {required this.youtubeExplodeRepository, required this.mtPlayerService})
      : super(const PlayerState.hidden());

  void init() {
    mtPlayerService.queue.listen((value) {
      if (value.isEmpty) {
        emit(const PlayerState.hidden());
      }
    });

    mtPlayerService.mediaItem.listen((value) {
      if (value == null && mtPlayerService.queue.value.isNotEmpty) {
        emit(const PlayerState.loading());
      } else if (value != null) {
        emit(const PlayerState.shown());
      }
    });
  }

  Future<void> startPlaying(String id) async {
    emit(const PlayerState.loading());

    try {
      await _startPlaying(id);
    } on Exception catch (e) {
      emit(PlayerState.error(e.toString()));
    }

    emit(const PlayerState.shown());
  }

  Future<void> startPlayingPlaylist(List<String> ids) async {
    emit(const PlayerState.loading(operation: LoadingOperation.play));
    // svuoto la coda
    try {
      await mtPlayerService.clearQueue();
      await _startPlayingPlaylist(ids);
    } on Exception catch (e) {
      emit(PlayerState.error(e.toString()));
      emit(const PlayerState.shown());
    }
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

  Future<void> _startPlaying(String id) async {
    await mtPlayerService.startPlaying(id);
  }

  Future<void> _startPlayingPlaylist(List<String> ids) async {
    bool firstVideoReady = false;

    await mtPlayerService.startPlayingPlaylist(
      ids,
      onFirstVideoReady: () {
        // Nasconde il progresso e mostra il mini player appena il primo video inizia
        if (!firstVideoReady) {
          firstVideoReady = true;
          emit(const PlayerState.shown());
        }
      },
      onProgress: (current, total) {
        // Mostra il progresso solo durante il caricamento del primo video
        if (!firstVideoReady) {
          emit(PlayerState.loadingWithProgress(
            current: current,
            total: total,
            operation: LoadingOperation.play,
          ));
        }
        // I progressi successivi vengono ignorati nella UI (caricamento in background)
      },
    );
  }

  Future<void> addToQueue(String id) async {
    try {
      await mtPlayerService.addToQueue(id);
      emit(const PlayerState.shown());
    } on Exception catch (e) {
      emit(PlayerState.error(e.toString()));
      // Torna allo stato precedente dopo l'errore
      emit(const PlayerState.shown());
    }
  }

  Future<void> addAllToQueue(List<String> ids) async {
    emit(const PlayerState.loading(operation: LoadingOperation.addToQueue));
    try {
      await mtPlayerService.addAllToQueue(
        ids,
        onProgress: (current, total) {
          emit(PlayerState.loadingWithProgress(
            current: current,
            total: total,
            operation: LoadingOperation.addToQueue,
          ));
        },
      );
    } on Exception catch (e) {
      emit(PlayerState.error(e.toString()));
    }
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

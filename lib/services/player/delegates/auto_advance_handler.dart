part of '../mt_player_service.dart';

/// Gestisce la logica di avanzamento automatico tra brani:
/// shuffle mode, repeat mode, e rilevamento fine traccia.
class AutoAdvanceHandler {
  AutoAdvanceHandler(this._service);
  final MtPlayerService _service;

  final Random _random = Random();
  final List<int> playedIndexesInShuffleMode = <int>[];

  bool get isShuffleModeEnabled =>
      _service.playbackState.value.shuffleMode == AudioServiceShuffleMode.all;

  bool get isRepeatModeAllEnabled =>
      _service.playbackState.value.repeatMode == AudioServiceRepeatMode.all;

  bool get allVideosPlayed =>
      playedIndexesInShuffleMode.length ==
      _service._queueManager.playlist.length;

  void resetShuffleHistory() {
    playedIndexesInShuffleMode.clear();
  }

  /// Chiamato dal listener del VideoPlayerController quando il brano è terminato.
  /// Calcola il prossimo indice e trasferisce il controllo a playAtIndex(),
  /// che gestisce autonomamente la serializzazione tramite token.
  void handleTrackEnded() {
    // Emetti subito lo stato buffering + playing per evitare che
    // Android Auto interpreti la fine del brano come pausa.
    _service.playbackState.add(_service.playbackState.value.copyWith(
      processingState: AudioProcessingState.buffering,
      playing: true,
    ));

    unawaited(Future(() async {
      try {
        if (isShuffleModeEnabled && isRepeatModeAllEnabled) {
          await skipToNextInShuffleMode();
        } else if (isShuffleModeEnabled) {
          if (allVideosPlayed) {
            await _service.stop();
          } else {
            await skipToNextInShuffleMode();
          }
        } else if (isRepeatModeAllEnabled) {
          await skipToNextInRepeatModeAll();
        } else {
          if (_service._queueManager.hasNextVideo) {
            await _service.skipToNext();
          } else {
            await _service.stop();
          }
        }
      } catch (e) {
        dev.log('Errore durante auto-skip: $e');
      }
    }));
  }

  Future<void> skipToNextInShuffleMode() async {
    final qm = _service._queueManager;

    if (isRepeatModeAllEnabled) {
      if (playedIndexesInShuffleMode.length == qm.playlist.length) {
        playedIndexesInShuffleMode.clear();
      }
    }

    final randomIndex = _random.nextInt(qm.playlist.length);

    if (playedIndexesInShuffleMode.contains(randomIndex)) {
      skipToNextInShuffleMode();
    } else if (qm.currentIndex != randomIndex) {
      playedIndexesInShuffleMode.add(randomIndex);
      await _service._engine.playAtIndex(randomIndex);
      _service.skipController.add(null);
    }
  }

  Future<void> skipToNextInRepeatModeAll() async {
    final qm = _service._queueManager;
    final nextIndex =
        qm.currentIndex < qm.playlist.length - 1 ? qm.currentIndex + 1 : 0;
    await _service._engine.playAtIndex(nextIndex);
    _service.skipController.add(null);
  }
}

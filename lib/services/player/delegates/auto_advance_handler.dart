part of '../mt_player_service.dart';

/// Gestisce la logica di avanzamento automatico tra brani:
/// shuffle mode, repeat mode, e rilevamento fine traccia.
class AutoAdvanceHandler {
  AutoAdvanceHandler(this._service);
  final MtPlayerService _service;

  final Random _random = Random();
  bool _isAutoAdvancing = false;
  final List<int> playedIndexesInShuffleMode = <int>[];

  bool get isAutoAdvancing => _isAutoAdvancing;

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
  /// Determina il prossimo brano in base alla modalità corrente.
  void handleTrackEnded() {
    _isAutoAdvancing = true;

    // Emetti subito lo stato buffering + playing per evitare che
    // Android Auto interpreti la fine del brano come pausa
    _service.playbackState.add(_service.playbackState.value.copyWith(
      processingState: AudioProcessingState.buffering,
      playing: true,
    ));

    // Esegui in un blocco async per gestire correttamente il flag _isAutoAdvancing
    unawaited(Future(() async {
      try {
        // verifica che ci siano altri brani nella coda
        if (isShuffleModeEnabled && isRepeatModeAllEnabled) {
          await skipToNextInShuffleMode();
        } else if (isShuffleModeEnabled) {
          // Caso in cui è attivo solo lo shuffle mode
          if (allVideosPlayed) {
            await _service.stop();
          } else {
            await skipToNextInShuffleMode();
          }
        } else if (isRepeatModeAllEnabled) {
          // Caso in cui è attivo solo il repeat all mode
          await skipToNextInRepeatModeAll();
        } else {
          // Caso in cui sono entrambi disattivi
          if (_service._queueManager.hasNextVideo) {
            await _service.skipToNext();
          } else {
            await _service.stop();
          }
        }
      } catch (e) {
        dev.log('Errore durante auto-skip: $e');
      } finally {
        _isAutoAdvancing = false;
      }
    }));
  }

  Future<void> skipToNextInShuffleMode() async {
    final qm = _service._queueManager;

    // se è attivo il repeat mode all, quando la lista playedIndexesInShuffleMode è piena, svuotala
    if (isRepeatModeAllEnabled) {
      if (playedIndexesInShuffleMode.length == qm.playlist.length) {
        playedIndexesInShuffleMode.clear();
      }
    }

    final randomIndex = _random.nextInt(qm.playlist.length);

    if (playedIndexesInShuffleMode.contains(randomIndex)) {
      // se l'indice è già stato riprodotto, riprova a generare un nuovo indice
      skipToNextInShuffleMode();
    } else if (qm.currentIndex != randomIndex) {
      qm.currentIndex = randomIndex;
      playedIndexesInShuffleMode.add(qm.currentIndex);
      await _service._engine.chewieController?.videoPlayerController
          .seekTo(Duration.zero);
      await _service._engine.playCurrentTrack();
      _service.skipController.add(null);
    }
  }

  Future<void> skipToNextInRepeatModeAll() async {
    final qm = _service._queueManager;

    if (qm.currentIndex < qm.playlist.length - 1) {
      qm.currentIndex++;
      await _service._engine.chewieController?.videoPlayerController
          .seekTo(Duration.zero);
      await _service._engine.playCurrentTrack();
      _service.skipController.add(null);
    } else {
      qm.currentIndex = 0;
      await _service._engine.chewieController?.videoPlayerController
          .seekTo(Duration.zero);
      await _service._engine.playCurrentTrack();
      _service.skipController.add(null);
    }
  }
}

part of '../mt_player_service.dart';

/// Gestisce il ciclo di vita dei controller video/audio,
/// lo stato di riproduzione e la sincronizzazione con audio_service.
class PlaybackEngine {
  PlaybackEngine(this._service);
  final MtPlayerService _service;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  VoidCallback? _currentPlayerListener;

  // Token di serializzazione: ogni chiamata a playAtIndex() imposta un nuovo
  // token. Il _doPlay in volo controlla il token ad ogni await; se il token è
  // cambiato significa che una richiesta più recente ha preso il controllo e
  // l'operazione corrente viene abortita pulitamente. Stesso principio del
  // Rx switchMap usato da Spotify/YouTube Music, senza dipendenze esterne.
  Object? _activeToken;

  /// True when playback was stopped intentionally (end of queue, user stop,
  /// notification dismissed, etc.).  Prevents Chewie's internal
  /// [WidgetsBindingObserver] from auto-resuming the video after the phone is
  /// unlocked: Chewie records "was playing" at lock-time and calls
  /// [VideoPlayerController.play] on resume regardless of whether the queue has
  /// since ended.  The flag is cleared whenever an intentional play request
  /// arrives via [play] or [playAtIndex].
  bool _intentionallyStopped = false;

  bool get isPreparing => _activeToken != null;

  // ============ Playback Controls ============

  Future<void> play() async {
    _intentionallyStopped = false;
    try {
      await chewieController?.videoPlayerController.play();
    } catch (e) {
      dev.log('Errore durante play: $e');
    }
  }

  Future<void> pause() async {
    try {
      await chewieController?.videoPlayerController.pause();
    } catch (e) {
      dev.log('Errore durante pause: $e');
    }
  }

  Future<void> stop() async {
    _intentionallyStopped = true;
    await chewieController?.videoPlayerController.pause();
    await chewieController?.videoPlayerController.seekTo(Duration.zero);
  }

  Future<void> seek(Duration position) async {
    await chewieController?.videoPlayerController.seekTo(position);
  }

  // ============ Core Playback ============

  /// Avvia la riproduzione dell'item all'indice [index] nella playlist.
  ///
  /// Serializza le richieste tramite token (pattern switchMap): se una nuova
  /// chiamata arriva mentre una è in corso, quella precedente viene annullata
  /// al prossimo await, dopo aver disposto pulitamente le risorse già allocate.
  ///
  /// [step] indica la direzione da seguire in caso di errore sullo stream:
  ///  - `1`  (default) = avanti → usato da auto-advance, next, tap su item
  ///  - `-1`           = indietro → usato da skipToPrevious
  /// In questo modo, se l'utente preme "precedente" e quel brano va in errore,
  /// l'auto-skip continua all'indietro invece di cambiare direzione.
  Future<void> playAtIndex(int index, {int step = 1}) async {
    // Rimuovi il listener corrente prima di qualsiasi await per evitare
    // callback spurie durante il teardown del controller esistente.
    _removeCurrentListener();
    _intentionallyStopped = false;

    // Pre-clear del flag di errore sull'item target: se l'utente retappa
    // un item che aveva già fallito, rimuoviamo subito il badge così la UI
    // non mostra più il warning mentre il caricamento è in corso.
    final qm = _service._queueManager;
    if (index >= 0 && index < qm.playlist.length) {
      final item = qm.playlist[index];
      final currentExtras = Map<String, dynamic>.from(item.extras ?? {});
      if (currentExtras['hasError'] == true) {
        currentExtras['hasError'] = false;
        qm.playlist[index] = item.copyWith(extras: currentExtras);
        _service.queue.add(qm.playlist);
      }
    }

    // Emetti un nuovo token: qualsiasi _doPlay in volo che legga il vecchio
    // token abortirà al prossimo check e libererà le proprie risorse.
    final token = Object();
    _activeToken = token;

    _service.playbackState.add(_service.playbackState.value.copyWith(
      processingState: AudioProcessingState.buffering,
      playing: true,
    ));

    try {
      await _doPlay(index, token);
    } catch (e) {
      dev.log('Errore durante playAtIndex($index): $e');
      // Se il token è ancora attivo (nessuna richiesta più recente), marca
      // l'item come in errore, notifica la UI e salta nella direzione [step].
      if (_activeToken == token) {
        if (index >= 0 && index < qm.playlist.length) {
          final item = qm.playlist[index];
          final errorExtras = Map<String, dynamic>.from(item.extras ?? {});
          errorExtras['hasError'] = true;
          qm.playlist[index] = item.copyWith(extras: errorExtras);
          _service.queue.add(qm.playlist);
          _service._onPlayErrorController.add((id: item.id, title: item.title));
        }
        final skipIndex = index + step;
        final playlist = qm.playlist;
        if (skipIndex >= 0 && skipIndex < playlist.length) {
          dev.log(
              'Stream error su index=$index: salto automatico a $skipIndex (step=$step)');
          unawaited(Future(() => playAtIndex(skipIndex, step: step)));
        }
      }
    } finally {
      if (_activeToken == token) {
        _activeToken = null;
        broadcastState();
      }
    }
  }

  Future<void> _doPlay(int index, Object token) async {
    final qm = _service._queueManager;

    // Cattura il track in una variabile locale immutabile rispetto alle
    // modifiche esterne: qm.currentTrack è un campo dell'istanza che altri
    // coroutine (es. stopPlayingAndClearMediaItem) possono nullificare tra un
    // await e l'altro. Usare 'var' permette l'aggiornamento via copyWith.
    var track = qm.playlist[index];
    qm.currentIndex = index;
    qm.currentTrack = track;
    final id = track.id;
    dev.log('_doPlay: index=$index id=$id "${track.title}"');

    // Segnala subito che "nessun item è in riproduzione": il listener in
    // PlayerCubit.init() lo trasforma in PlayerState.loading() se la coda
    // non è vuota. Questo garantisce che lo skeleton sia visibile per tutta
    // la durata dell'inizializzazione, indipendentemente da chi ha chiamato
    // playAtIndex (PlayerCubit, auto-advance, skip da notifica, ecc.).
    _service.mediaItem.add(null);

    // ── Dispose vecchio controller ──────────────────────────────────────────
    if (chewieController != null || videoPlayerController != null) {
      await _disposeControllers();
    }
    if (_activeToken != token) {
      dev.log('_doPlay cancelled after dispose (id=$id)');
      return;
    }

    // ── Fetch stream URL sempre fresco dall'AppCache (mai dagli extras) ─────
    dev.log('Fetching stream URL for: $id');
    final streamUrl = await getStreamUrl(id);
    dev.log('Stream URL fetched for: $id');
    if (_activeToken != token) {
      dev.log('_doPlay cancelled after getStreamUrl (id=$id)');
      return;
    }

    // ── Inizializza VideoPlayerController ───────────────────────────────────
    dev.log('Initializing VideoPlayerController...');
    final vpc = VideoPlayerController.networkUrl(
      Uri.parse(streamUrl),
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );
    videoPlayerController = vpc;
    await vpc.initialize();
    dev.log('VideoPlayerController initialized');

    if (_activeToken != token) {
      await vpc.dispose();
      videoPlayerController = null;
      dev.log('_doPlay cancelled after initialize (id=$id)');
      return;
    }

    // ── Aggiorna durata effettiva se necessario ──────────────────────────────
    final videoDuration = vpc.value.duration;
    if (videoDuration > Duration.zero &&
        (track.duration == null || track.duration == Duration.zero)) {
      track = track.copyWith(duration: videoDuration);
      qm.currentTrack = track;
      qm.playlist[qm.currentIndex] = track;
    }

    // ── Avvia riproduzione ──────────────────────────────────────────────────
    await vpc.play();
    dev.log('VideoPlayerController.play() called');
    if (_activeToken != token) {
      dev.log('_doPlay cancelled after play() (id=$id)');
      return;
    }

    // ── Delay per propagazione stato su Android Auto hardware ───────────────
    await Future.delayed(const Duration(milliseconds: 150));
    if (_activeToken != token) {
      dev.log('_doPlay cancelled after delay (id=$id)');
      return;
    }

    // ── Crea ChewieController ───────────────────────────────────────────────
    dev.log('Creating ChewieController...');
    chewieController = ChewieController(
      videoPlayerController: vpc,
      autoPlay: true,
      showOptions: false,
      routePageBuilder: (context, animation, __, ___) {
        return FullScreenVideoView(mtPlayerService: _service);
      },
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
    dev.log('ChewieController created');
    if (_activeToken != token) {
      dev.log('_doPlay cancelled after ChewieController (id=$id)');
      return;
    }

    // ── Broadcast finale, queue, listener e pre-warm ────────────────────────
    // mediaItem viene emesso solo ora: il listener di PlayerCubit.init()
    // riceve un valore non-null → emit(shown()), lo skeleton scompare.
    _service.queue.add(qm.playlist);
    _service.mediaItem.add(track);
    broadcastState();
    _setupPlaybackListener();
    _warmNextTrackCache();
  }

  // ============ State Broadcasting ============

  /// Sincronizza lo stato del player con audio_service e tutti i listeners
  void broadcastState() {
    try {
      AudioProcessingState audioProcessingState() {
        if (chewieController == null) return AudioProcessingState.idle;
        final value = chewieController!.videoPlayerController.value;
        if (value.isBuffering) return AudioProcessingState.buffering;
        if (value.isInitialized) return AudioProcessingState.ready;
        return AudioProcessingState.idle;
      }

      bool isPlaying() {
        if (_activeToken != null) return true;
        if (chewieController == null) return false;
        final value = chewieController!.videoPlayerController.value;
        return value.isPlaying || value.isBuffering;
      }

      // Protezione per Android Auto - evita errori quando il controller non è disponibile
      if (chewieController == null ||
          !chewieController!.videoPlayerController.value.isInitialized) {
        final isBuffering = _service.playbackState.value.processingState ==
                AudioProcessingState.buffering ||
            _activeToken != null;
        _service.playbackState.add(_service.playbackState.value.copyWith(
          processingState: isBuffering
              ? AudioProcessingState.buffering
              : AudioProcessingState.idle,
          playing: _activeToken != null,
        ));
        return;
      }

      _service.playbackState.add(_service.playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (_service.playbackState.value.playing)
              MediaControl.pause
            else
              MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
          },
          androidCompactActionIndices: const [
            0,
            1,
            3
          ],
          processingState: audioProcessingState(),
          playing: isPlaying(),
          updatePosition:
              chewieController!.videoPlayerController.value.position,
          bufferedPosition: chewieController!
                  .videoPlayerController.value.buffered.isNotEmpty
              ? chewieController!.videoPlayerController.value.buffered.last.end
              : Duration.zero,
          speed: chewieController!.videoPlayerController.value.playbackSpeed,
          queueIndex: _service._queueManager.currentIndex));
    } catch (e) {
      dev.log('Errore in _broadcastState: $e');
      // Fallback state per Android Auto
      _service.playbackState.add(_service.playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: _activeToken != null,
      ));
    }
  }

  // ============ Listener Management ============

  /// Configura il listener per il rilevamento fine traccia e aggiornamento stato
  void _setupPlaybackListener() {
    _currentPlayerListener = () {
      // Protezione: se il controller è stato disposed, non procedere
      if (chewieController == null) return;
      final value = chewieController!.videoPlayerController.value;

      // Chewie has an internal WidgetsBindingObserver that records whether the
      // video was playing when the phone was locked and calls
      // videoPlayerController.play() on unlock, regardless of whether the
      // queue has since ended.  If we intentionally stopped (end of queue,
      // user/notification stop), intercept that auto-resume and re-pause
      // immediately before broadcasting any state to the rest of the app.
      if (_intentionallyStopped && value.isPlaying) {
        unawaited(chewieController!.videoPlayerController.pause());
        return;
      }

      broadcastState();
      final hasEnded = value.isInitialized &&
          value.duration > Duration.zero &&
          value.position >= value.duration;

      // Controlla _intentionallyStopped per evitare auto-advance spurio quando
      // stop() mette in pausa un video quasi terminato (isPlaying=false, ma
      // hasEnded potrebbe essere true). Questo era la race condition principale.
      if (hasEnded && !_intentionallyStopped) {
        _service._autoAdvance.handleTrackEnded();
      }

      if (value.hasError) {
        dev.log('Errore di riproduzione: ${value.errorDescription}');
      }
    };
    chewieController?.videoPlayerController
        .addListener(_currentPlayerListener!);
  }

  void _removeCurrentListener() {
    if (_currentPlayerListener != null && videoPlayerController != null) {
      try {
        videoPlayerController!.removeListener(_currentPlayerListener!);
      } catch (e) {
        dev.log('Errore rimozione listener: $e');
      }
      _currentPlayerListener = null;
    }
  }

  // ============ Controller Lifecycle ============

  Future<void> disposeControllers() async {
    _removeCurrentListener();
    await chewieController?.videoPlayerController.dispose();
    chewieController?.dispose();
    chewieController = null;
    videoPlayerController = null;
  }

  // Alias privato per uso interno (mantiene compatibilità col codice originale)
  Future<void> _disposeControllers() => disposeControllers();

  // ============ Media Item & Stream URL ============

  Future<MediaItem> createMediaItem(String id) async {
    final repo = _service.youtubeExplodeRepository;
    final video = repo != null
        ? await repo.getCachedVideo(id)
        : await _service.youtubeExplodeProvider.getVideo(id);

    return MediaItem(
      id: video.id.value,
      title: video.title,
      album: video.musicData.isNotEmpty
          ? video.musicData.first.album
          : video.author,
      artUri: Uri.parse(video.thumbnails.highResUrl),
      duration: video.duration,
      extras: {
        'description': video.description,
      },
    );
  }

  /// Converts a [VideoTile] to a [MediaItem] without any network requests.
  /// Used for eagerly appending related videos to the queue.
  static MediaItem mediaItemFromVideoTile(VideoTile tile) {
    return MediaItem(
      id: tile.id,
      title: tile.title,
      album: tile.artist,
      artUri: Uri.parse(tile.thumbnailUrl),
      duration: tile.duration,
    );
  }

  Future<String> getStreamUrl(String id) async {
    // Usa la cache del repository se disponibile per evitare chiamate di rete ripetute
    final repo = _service.youtubeExplodeRepository;
    if (repo != null) {
      return repo.getCachedStreamUrl(id);
    }
    final manifest =
        await _service.youtubeExplodeProvider.getVideoStreamManifest(id);
    return manifest.muxed.isNotEmpty
        ? manifest.muxed.withHighestBitrate().url.toString()
        : manifest.audioOnly.withHighestBitrate().url.toString();
  }

  // ============ Repeat Mode ============

  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (repeatMode == AudioServiceRepeatMode.one) {
      await chewieController?.videoPlayerController.setLooping(true);
    } else {
      await chewieController?.videoPlayerController.setLooping(false);
    }

    _service.playbackState
        .add(_service.playbackState.value.copyWith(repeatMode: repeatMode));
  }

  // ============ Pre-warm cache ============

  /// Richiede lo stream URL del prossimo brano in background, cosi l'AppCache
  /// sarà pronto quando toccherà a lui. Non muta mai la playlist.
  void _warmNextTrackCache() {
    final qm = _service._queueManager;
    if (qm.hasNextVideo) {
      final nextTrack = qm.playlist[qm.currentIndex + 1];
      unawaited(() async {
        try {
          await getStreamUrl(nextTrack.id);
        } catch (e) {
          dev.log('Errore pre-warm cache per ${nextTrack.id}: $e');
        }
      }());
    }
  }
}

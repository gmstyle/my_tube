part of '../mt_player_service.dart';

/// Gestisce il ciclo di vita dei controller video/audio,
/// lo stato di riproduzione e la sincronizzazione con audio_service.
class PlaybackEngine {
  PlaybackEngine(this._service);
  final MtPlayerService _service;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  bool _isPreparing = false;
  VoidCallback? _currentPlayerListener;

  bool get isPreparing => _isPreparing;

  // ============ Playback Controls ============

  Future<void> play() async {
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
    await chewieController?.videoPlayerController.pause();
    await chewieController?.videoPlayerController.seekTo(Duration.zero);
  }

  Future<void> seek(Duration position) async {
    await chewieController?.videoPlayerController.seekTo(position);
  }

  // ============ Core Playback ============

  Future<void> playCurrentTrack() async {
    dev.log('--- _playCurrentTrack started ---');

    // Rimuovi il listener dal controller corrente PRIMA di qualsiasi altra operazione
    // per evitare callback spurie durante il teardown
    _removeCurrentListener();

    _isPreparing = true;
    try {
      // Segnala che stiamo caricando (buffering state per Android Auto)
      // Mantieni playing: true per tutto il ciclo di transizione
      _service.playbackState.add(_service.playbackState.value.copyWith(
        processingState: AudioProcessingState.buffering,
        playing: true,
      ));

      final qm = _service._queueManager;
      qm.currentTrack = qm.playlist[qm.currentIndex];
      dev.log(
          'Current item: ${qm.currentTrack?.id} - ${qm.currentTrack?.title}');

      // Non settiamo a null se abbiamo già un track (evita schermate nere improvvise)
      if (qm.currentTrack != null) {
        _service.mediaItem.add(qm.currentTrack);
      } else {
        _service.mediaItem.add(null);
      }

      if (chewieController != null && videoPlayerController != null) {
        await _disposeControllers();
      }

      // Carica lo stream URL se non è ancora stato caricato
      if (qm.currentTrack?.extras?['streamUrl'] == null) {
        dev.log('Fetching stream URL for: ${qm.currentTrack?.id}');
        final streamUrl = await getStreamUrl(qm.currentTrack!.id);
        dev.log('Stream URL fetched successfully');
        qm.currentTrack = qm.currentTrack!.copyWith(
          extras: {
            ...qm.currentTrack!.extras ?? {},
            'streamUrl': streamUrl,
          },
        );
        // Aggiorna anche nella playlist
        qm.playlist[qm.currentIndex] = qm.currentTrack!;
      }

      dev.log('Initializing VideoPlayerController...');
      // inizializza il video player controller da passare a chewie
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(qm.currentTrack?.extras!['streamUrl']),
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
      );

      await videoPlayerController!.initialize();
      dev.log('VideoPlayerController initialized');

      // Aggiorna la durata effettiva se disponibile
      final videoDuration = videoPlayerController!.value.duration;
      if (videoDuration > Duration.zero &&
          (qm.currentTrack?.duration == null ||
              qm.currentTrack?.duration == Duration.zero)) {
        qm.currentTrack = qm.currentTrack!.copyWith(duration: videoDuration);
        qm.playlist[qm.currentIndex] = qm.currentTrack!;
        _service.mediaItem.add(qm.currentTrack);
        _service.queue.add(qm.playlist);
      }

      // Forza il play immediato per notifiche e background
      await videoPlayerController!.play();
      dev.log('VideoPlayerController.play() called');

      // Attendi un breve momento per assicurare la propagazione dello stato
      // su Android Auto hardware reale (più sensibile dell'emulatore)
      await Future.delayed(const Duration(milliseconds: 150));

      // inizializza il chewie controller per la riproduzione del video
      dev.log('Creating ChewieController...');
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        showOptions: false,
        routePageBuilder: (context, animation, __, ___) {
          // uso un widget per il full screen personalizzato
          // per poter gestire il cambio di brano anche in full screen
          return FullScreenVideoView(
            mtPlayerService: _service,
          );
        },
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );
      dev.log('ChewieController created');

      // inizializza lo stato iniziale
      broadcastState();

      // aggiungi il brano alla coda
      _service.queue.add(qm.playlist);
      // aggiungi il brano al media item per la notifica
      _service.mediaItem.add(qm.currentTrack);

      // propaga lo stato del player ad audio_service e a tutti i listeners
      _setupPlaybackListener();

      // Pre-fetching del prossimo brano per velocizzare la transizione
      _prefetchNextTrack();
    } catch (e) {
      dev.log('Errore durante _playCurrentTrack: $e');
    } finally {
      _isPreparing = false;
      broadcastState();
    }
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
        if (_isPreparing || _service._autoAdvance._isAutoAdvancing) return true;
        if (chewieController == null) return false;
        final value = chewieController!.videoPlayerController.value;
        return value.isPlaying || value.isBuffering;
      }

      // Protezione per Android Auto - evita errori quando il controller non è disponibile
      if (chewieController == null ||
          !chewieController!.videoPlayerController.value.isInitialized) {
        final isBuffering = _service.playbackState.value.processingState ==
                AudioProcessingState.buffering ||
            _isPreparing;
        _service.playbackState.add(_service.playbackState.value.copyWith(
          processingState: isBuffering
              ? AudioProcessingState.buffering
              : AudioProcessingState.idle,
          playing: _isPreparing || _service._autoAdvance._isAutoAdvancing,
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
        playing: _isPreparing || _service._autoAdvance._isAutoAdvancing,
      ));
    }
  }

  // ============ Listener Management ============

  /// Configura il listener per il rilevamento fine traccia e aggiornamento stato
  void _setupPlaybackListener() {
    _currentPlayerListener = () {
      broadcastState();
      // Protezione: se il controller è stato disposed, non procedere
      if (chewieController == null) return;
      final value = chewieController!.videoPlayerController.value;
      final hasEnded = value.isInitialized &&
          value.duration > Duration.zero &&
          value.position >= value.duration;

      if (hasEnded && !_service._autoAdvance._isAutoAdvancing) {
        _service._autoAdvance.handleTrackEnded();
      }

      if (value.hasError) {
        if (kDebugMode) {
          print('Errore di riproduzione: ${value.errorDescription}');
        }
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

  Future<MediaItem> createMediaItem(String id,
      {bool loadStreamUrl = false}) async {
    final video = await _service.youtubeExplodeProvider.getVideo(id);

    String? muxedStream;
    if (loadStreamUrl) {
      final manifest =
          await _service.youtubeExplodeProvider.getVideoStreamManifest(id);
      muxedStream = manifest.muxed.isNotEmpty
          ? manifest.muxed.withHighestBitrate().url.toString()
          : manifest.audioOnly.withHighestBitrate().url.toString();
    }

    return MediaItem(
        id: video.id.value,
        title: video.title,
        album: video.musicData.isNotEmpty ? video.musicData.first.album : null,
        artUri: Uri.parse(video.thumbnails.highResUrl),
        duration: video.duration,
        extras: {
          'streamUrl': muxedStream,
          'description': video.description,
        });
  }

  Future<String> getStreamUrl(String id) async {
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

  // ============ Pre-fetching ============

  void _prefetchNextTrack() {
    final qm = _service._queueManager;
    if (qm.hasNextVideo) {
      final nextIndex = qm.currentIndex + 1;
      final nextTrack = qm.playlist[nextIndex];
      if (nextTrack.extras?['streamUrl'] == null) {
        unawaited(getStreamUrl(nextTrack.id).then((url) {
          qm.playlist[nextIndex] = nextTrack.copyWith(
            extras: {
              ...nextTrack.extras ?? {},
              'streamUrl': url,
            },
          );
          _service.queue.add(qm.playlist);
          dev.log('Pre-fetched stream URL for next track: ${nextTrack.id}');
        }).catchError((e) {
          dev.log('Errore pre-fetching prossimo brano: $e');
        }));
      }
    }
  }
}

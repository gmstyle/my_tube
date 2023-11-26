import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/song_view/widget/full_screen_video_view.dart';
import 'package:video_player/video_player.dart';

import '../respositories/queue_repository.dart';

class MtPlayerHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final QueueRepository queueRepository = QueueRepository();
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  int currentIndex = 0;
  late MediaItem currentTrack;
  List<MediaItem> playlist = [];
  bool get hasNextVideo => currentIndex < playlist.length - 1;
  bool shuffleEnabled = false;

  // Stream per notificare il cambio di brano
  final StreamController<void> skipController =
      StreamController<void>.broadcast();
  Stream<void> get onSkip => skipController.stream;

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await _setRepeatMode(repeatMode);
  }

  @override
  Future<void> play() async {
    await chewieController.videoPlayerController.play();
  }

  @override
  Future<void> pause() async {
    await chewieController.videoPlayerController.pause();
  }

  @override
  Future<void> stop() async {
    await chewieController.videoPlayerController.pause();
    await chewieController.videoPlayerController.seekTo(Duration.zero);
  }

  @override
  Future<void> seek(Duration position) async {
    await chewieController.videoPlayerController.seekTo(position);
  }

  @override
  Future<void> skipToPrevious() async {
    if (currentIndex > 0) {
      currentIndex--;
      await chewieController.videoPlayerController.seekTo(Duration.zero);
      await _playCurrentTrack();
      skipController.add(null);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      await chewieController.videoPlayerController.seekTo(Duration.zero);
      await _playCurrentTrack();
      skipController.add(null);
    }
  }

  // Inizializza currentIndex, playlist e currentTrack da hive
  Future<void> init() async {
    //queueRepository.clear();
    //currentIndex = queueRepository.currentIndex;
    final localQueue = queueRepository.queue;

    for (final video in localQueue) {
      playlist.add(MediaItem(
          id: video.id!,
          title: video.title!,
          album: video.channelTitle!,
          artUri: Uri.parse(video.thumbnailUrl!),
          duration: Duration(milliseconds: video.duration!),
          extras: {
            'streamUrl': video.streamUrl!,
            'description': video.description,
          }));
    }
    currentTrack = playlist[currentIndex];

    /*  // inizializza il video player controller da passare a chewie
    videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(currentTrack.extras!['streamUrl']),
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
    await videoPlayerController.initialize();

    // inizializza il chewie controller per la riproduzione del video
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      showOptions: false,
      routePageBuilder: (context, animation, __, ___) {
        // uso un widget per il full screen personalizzato
        // per poter gestire il cambio di brano anche in full screen
        return FullScreenVideoView(
          mtPlayerHandler: this,
        );
      },
    );

    // aggiungi il brano alla coda
    queue.add(playlist);
    // aggiungi il brano al media item per la notifica
    mediaItem.add(currentTrack); */

    // propaga lo stato del player ad audio_service e a tutti i listeners
    //chewieController.videoPlayerController.addListener(broadcastState);
  }

  // Inizializza il player per la riproduzione singola
  Future<void> startPlaying(ResourceMT video) async {
    // inizializza il media item da passare riprodurre
    final item = MediaItem(
        id: video.id!,
        title: video.title!,
        album: video.channelTitle!,
        artUri: Uri.parse(video.thumbnailUrl!),
        duration: Duration(milliseconds: video.duration!),
        extras: {
          'streamUrl': video.streamUrl!,
          'description': video.description,
        });

    // aggiungi il brano alla coda se non è già presente
    if (!playlist.contains(item)) {
      playlist.add(item);
      // salva il brano nella coda locale
      await queueRepository.save(video);
    }

    currentIndex = playlist.indexOf(item);

    await _playCurrentTrack();
  }

  // Inizializza il player per la riproduzione di una coda di video
  Future<void> startPlayingPlaylist(List<ResourceMT> videos) async {
    // inizializza la playlist ed il primo brano
    final list = videos
        .map((video) => MediaItem(
                id: video.id!,
                title: video.title!,
                album: video.channelTitle!,
                artUri: Uri.parse(video.thumbnailUrl!),
                duration: Duration(milliseconds: video.duration!),
                extras: {
                  'streamUrl': video.streamUrl!,
                }))
        .toList();

    for (final item in list) {
      // aggiungi il brano alla coda se non è già presente
      if (!playlist.contains(item)) {
        playlist.add(item);
        // salva il brano nella coda locale
        await queueRepository.save(videos[list.indexOf(item)]);
      }
    }

    currentIndex = playlist.indexOf(list.first);

    await _playCurrentTrack();
  }

  // prepara lo stato del player per la riproduzione
  void _broadcastState() {
    bool isPlaying() => chewieController.videoPlayerController.value.isPlaying;

    AudioProcessingState audioProcessingState() {
      if (chewieController.videoPlayerController.value.isInitialized) {
        return AudioProcessingState.ready;
      }
      return AudioProcessingState.idle;
    }

    playbackState.add(playbackState.value.copyWith(
        controls: [
          if (currentIndex > 0) MediaControl.skipToPrevious,
          if (playbackState.value.playing)
            MediaControl.pause
          else
            MediaControl.play,
          if (currentIndex < playlist.length - 1) MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [
          0,
          1,
          2
        ],
        processingState: audioProcessingState(),
        playing: isPlaying(),
        updatePosition: chewieController.videoPlayerController.value.position,
        speed: chewieController.videoPlayerController.value.playbackSpeed,
        queueIndex: currentIndex));
  }

  Future<void> _playCurrentTrack() async {
    currentTrack = playlist[currentIndex];

    // inizializza il video player controller da passare a chewie
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(currentTrack.extras!['streamUrl']),
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );
    await videoPlayerController.initialize();

    // inizializza il chewie controller per la riproduzione del video
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      showOptions: false,
      routePageBuilder: (context, animation, __, ___) {
        // uso un widget per il full screen personalizzato
        // per poter gestire il cambio di brano anche in full screen
        return FullScreenVideoView(
          mtPlayerHandler: this,
        );
      },
    );

    // aggiungi il brano alla coda
    queue.add(playlist);
    // aggiungi il brano al media item per la notifica
    mediaItem.add(currentTrack);

    // propaga lo stato del player ad audio_service e a tutti i listeners
    chewieController.videoPlayerController.addListener(_broadcastState);

    chewieController.videoPlayerController.addListener(() {
      // verifica che il video sia finito
      if (chewieController.videoPlayerController.value.duration ==
          chewieController.videoPlayerController.value.position) {
        // verifica che ci siano altri brani nella coda
        if (hasNextVideo) {
          skipToNext();
        } else {
          stop();
        }
      }
    });
  }

  Future<void> _setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (repeatMode == AudioServiceRepeatMode.none) {
      await chewieController.videoPlayerController.setLooping(false);
    } else {
      await chewieController.videoPlayerController.setLooping(true);
    }
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  Future<void> addToQueue(ResourceMT video) async {
    final item = MediaItem(
        id: video.id!,
        title: video.title!,
        album: video.channelTitle!,
        artUri: Uri.parse(video.thumbnailUrl!),
        duration: Duration(milliseconds: video.duration!),
        extras: {
          'streamUrl': video.streamUrl!,
          'description': video.description,
        });

    // aggiungi il brano alla coda se non è già presente
    if (!playlist.contains(item)) {
      playlist.add(item);
      // salva il brano nella coda locale
      await queueRepository.save(video);
    }
    queue.add(playlist);

    if (currentIndex == -1) {
      currentIndex = playlist.indexOf(item);
      await _playCurrentTrack();
    }
  }

  Future<void> removeFromQueue(ResourceMT video) async {
    final index = playlist.indexOf(MediaItem(
        id: video.id!,
        title: video.title!,
        album: video.channelTitle!,
        artUri: Uri.parse(video.thumbnailUrl!),
        duration: Duration(milliseconds: video.duration!),
        extras: {
          'streamUrl': video.streamUrl!,
        }));
    await queueRepository.remove(video);
    playlist.removeAt(index);
    queue.add(playlist);

    if (index < currentIndex) {
      currentIndex--;
    } else if (index == currentIndex) {
      if (hasNextVideo) {
        skipToNext();
      } else {
        stop();
      }
    } else {
      currentIndex = playlist.indexOf(currentTrack);
    }
  }

  Future<void> clearQueue() async {
    stop();
    await queueRepository.clear();
    playlist.clear();
    queue.add(playlist);
  }

  Future<void> toggleShuffle() async {
    shuffleEnabled = !shuffleEnabled;
    if (shuffleEnabled) {
      _shufflePlaylist();
    } else {
      // ripristina la playlist originale
      playlist = queueRepository.queue.map((e) {
        return MediaItem(
            id: e.id!,
            title: e.title!,
            album: e.channelTitle!,
            artUri: Uri.parse(e.thumbnailUrl!),
            duration: Duration(milliseconds: e.duration!),
            extras: {
              'streamUrl': e.streamUrl!,
              'description': e.description,
            });
      }).toList();
      currentIndex = playlist.indexOf(currentTrack);
      await _playCurrentTrack();
    }
  }

  Future<void> _shufflePlaylist() async {
    final random = Random();
    final List<MediaItem> shuffledPlaylist = List.from(playlist);

    // Usa l'algoritmo di Fisher-Yates per mescolare la playlist
    for (int i = shuffledPlaylist.length - 1; i > 0; i--) {
      final int j = random.nextInt(i + 1);
      final MediaItem temp = shuffledPlaylist[i];
      shuffledPlaylist[i] = shuffledPlaylist[j];
      shuffledPlaylist[j] = temp;
    }

    // Aggiorna la playlist e riproduci la prima traccia mescolata
    playlist = shuffledPlaylist;
    currentIndex = 0;

    await chewieController.videoPlayerController.seekTo(Duration.zero);
    await _playCurrentTrack();
    skipController.add(null);
  }
}

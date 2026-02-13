import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/respositories/favorite_repository.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/services/player/delegates/android_auto/android_auto_content_helper.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:my_tube/providers/youtube_explode_provider.dart';
import 'package:my_tube/services/bulk_video_loader.dart';
import 'package:my_tube/ui/views/video/widget/full_screen_video_view.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'delegates/playback_engine.dart';
part 'delegates/queue_manager.dart';
part 'delegates/auto_advance_handler.dart';
part 'delegates/android_auto/android_auto_browsing_service.dart';

/// Servizio principale per la riproduzione media.
///
/// Funge da façade che delega alle seguenti componenti interne:
/// - [PlaybackEngine]: gestione controller video/audio e stato riproduzione
/// - [QueueManager]: gestione playlist e coda
/// - [AutoAdvanceHandler]: logica shuffle, repeat e auto-advance
/// - [AndroidAutoBrowsingService]: browsing e ricerca per Android Auto
class MtPlayerService extends BaseAudioHandler with QueueHandler, SeekHandler {
  MtPlayerService({
    required this.youtubeExplodeProvider,
    this.favoriteRepository,
    this.youtubeExplodeRepository,
  });

  final YoutubeExplodeProvider youtubeExplodeProvider;
  final FavoriteRepository? favoriteRepository;
  final YoutubeExplodeRepository? youtubeExplodeRepository;

  // ============ Delegate Components ============

  late final PlaybackEngine _engine = PlaybackEngine(this);
  late final QueueManager _queueManager = QueueManager(this);
  late final AutoAdvanceHandler _autoAdvance = AutoAdvanceHandler(this);
  late final AndroidAutoBrowsingService _browsing =
      AndroidAutoBrowsingService(this);

  // ============ Public Getters (delegation) ============

  VideoPlayerController? get videoPlayerController =>
      _engine.videoPlayerController;
  ChewieController? get chewieController => _engine.chewieController;
  int get currentIndex => _queueManager.currentIndex;
  set currentIndex(int value) => _queueManager.currentIndex = value;
  MediaItem? get currentTrack => _queueManager.currentTrack;
  set currentTrack(MediaItem? value) => _queueManager.currentTrack = value;
  List<MediaItem> get playlist => _queueManager.playlist;
  set playlist(List<MediaItem> value) => _queueManager.playlist = value;
  bool get hasNextVideo => _queueManager.hasNextVideo;
  bool get isShuffleModeEnabled => _autoAdvance.isShuffleModeEnabled;
  bool get isRepeatModeAllEnabled => _autoAdvance.isRepeatModeAllEnabled;

  // Stream per notificare il cambio di brano alla UI FullScreenView
  final StreamController<void> skipController =
      StreamController<void>.broadcast();
  Stream<void> get onSkip => skipController.stream;

  // ============ Playback Controls (BaseAudioHandler overrides) ============

  @override
  Future<void> play() => _engine.play();

  @override
  Future<void> pause() => _engine.pause();

  @override
  Future<void> stop() => _engine.stop();

  @override
  Future<void> seek(Duration position) => _engine.seek(position);

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    try {
      _autoAdvance.resetShuffleHistory();
      playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
    } catch (e) {
      dev.log('Errore durante setShuffleMode: $e');
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    try {
      await _engine.setRepeatMode(repeatMode);
    } catch (e) {
      dev.log('Errore durante setRepeatMode: $e');
    }
  }

  // ============ Skip Controls ============

  @override
  Future<void> skipToPrevious() async {
    if (_queueManager.currentIndex > 0) {
      _queueManager.currentIndex--;
      await _engine.chewieController?.videoPlayerController
          .seekTo(Duration.zero);
      await _engine.playCurrentTrack();
      skipController.add(null);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (_queueManager.currentIndex < _queueManager.playlist.length - 1) {
      _queueManager.currentIndex++;
      await _engine.chewieController?.videoPlayerController
          .seekTo(Duration.zero);
      await _engine.playCurrentTrack();
      skipController.add(null);
    }
  }

  Future<void> skipToNextInShuffleMode() =>
      _autoAdvance.skipToNextInShuffleMode();

  Future<void> skipToNextInRepeatModeAll() =>
      _autoAdvance.skipToNextInRepeatModeAll();

  // ============ Public Playback API ============

  Future<void> startPlaying(String id) => _queueManager.startPlaying(id);

  Future<void> startPlayingPlaylist(
    List<String> ids, {
    Function(int current, int total)? onProgress,
    VoidCallback? onFirstVideoReady,
  }) =>
      _queueManager.startPlayingPlaylist(ids,
          onProgress: onProgress, onFirstVideoReady: onFirstVideoReady);

  // ============ Queue Management API ============

  Future<void> addToQueue(String id) => _queueManager.addToQueue(id);

  Future<void> addAllToQueue(
    List<String> ids, {
    Function(int current, int total)? onProgress,
  }) =>
      _queueManager.addAllToQueue(ids, onProgress: onProgress);

  Future<bool?> removeFromQueue(String id) => _queueManager.removeFromQueue(id);

  Future<void> clearQueue() => _queueManager.clearQueue();

  Future<void> stopPlayingAndClearQueue() =>
      _queueManager.stopPlayingAndClearQueue();

  Future<void> stopPlayingAndClearMediaItem() =>
      _queueManager.stopPlayingAndClearMediaItem();

  Future<void> reorderQueue(int oldIndex, int newIndex) =>
      _queueManager.reorderQueue(oldIndex, newIndex);

  // ============ Android Auto Overrides ============

  @override
  Future<void> onTaskRemoved() async {
    try {
      await stop();
    } catch (e) {
      dev.log('Errore durante onTaskRemoved: $e');
    }
  }

  @override
  Future<void> onNotificationDeleted() async {
    try {
      await stop();
    } catch (e) {
      dev.log('Errore durante onNotificationDeleted: $e');
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) =>
      _browsing.playMediaItem(mediaItem);

  @override
  Future<void> playFromMediaId(String mediaId,
          [Map<String, dynamic>? extras]) =>
      _browsing.playFromMediaId(mediaId, extras);

  @override
  Future<void> addQueueItem(MediaItem mediaItem) =>
      _browsing.addQueueItem(mediaItem);

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) =>
      _browsing.addQueueItems(mediaItems);

  @override
  Future<List<MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) =>
      _browsing.getChildren(parentMediaId, options);

  @override
  Future<List<MediaItem>> search(
    String query, [
    Map<String, dynamic>? extras,
  ]) =>
      _browsing.search(query, extras);
}

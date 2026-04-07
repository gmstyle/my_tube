import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/video/widget/controls.dart';
import 'package:my_tube/ui/views/video/widget/mediaitem_tile.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/clear_queue_button.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/play_pause_gesture_detector_mediaitem.dart';

class QueueView extends StatefulWidget {
  const QueueView({super.key});

  @override
  State<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  late final PlayerCubit _playerCubit;
  late final PersistentUiCubit _persistentUiCubit;
  StreamSubscription<List<MediaItem>>? _queueSubscription;
  final ScrollController _scrollController = ScrollController();
  List<MediaItem> _queue = [];
  bool _isCollapsed = false;

  static const double _kExpandedHeight = 220.0;
  // SliverAppBar collassa quando l'offset supera expandedHeight - toolbar height.
  static const double _kCollapseThreshold = _kExpandedHeight - kToolbarHeight;

  @override
  void initState() {
    super.initState();
    _playerCubit = context.read<PlayerCubit>();
    _persistentUiCubit = context.read<PersistentUiCubit>();
    _queue = List.from(_playerCubit.mtPlayerService.playlist);
    _scrollController.addListener(_onScroll);

    _queueSubscription = _playerCubit.mtPlayerService.queue.listen((queue) {
      if (queue.isEmpty && mounted) {
        context.pop();
        return;
      }
      if (mounted) setState(() => _queue = queue);
    });

    // Hide mini player after the push animation so it doesn't float over the queue.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _persistentUiCubit.setPlayerVisibility(false);
    });
  }

  @override
  void dispose() {
    _queueSubscription?.cancel();
    _scrollController.dispose();
    // Restore mini player when leaving the queue.
    _persistentUiCubit.setPlayerVisibility(true);
    super.dispose();
  }

  void _onScroll() {
    final collapsed = _scrollController.hasClients &&
        _scrollController.offset >= _kCollapseThreshold;
    if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              tooltip: 'Back',
              onPressed: () => context.pop(),
            ),
            title: _isCollapsed
                ? StreamBuilder(
                    stream: _playerCubit.mtPlayerService.mediaItem,
                    builder: (context, snapshot) => Text(
                      snapshot.data?.title ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : null,
            actions: [
              if (_isCollapsed) ...[
                StreamBuilder(
                  stream: _playerCubit.mtPlayerService.playbackState
                      .map((s) => s.playing)
                      .distinct(),
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () => isPlaying
                          ? _playerCubit.mtPlayerService.pause()
                          : _playerCubit.mtPlayerService.play(),
                    );
                  },
                ),
              ],
              const ClearQueueButton(),
            ],
            expandedHeight: _kExpandedHeight,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _ExpandedPlayer(playerCubit: _playerCubit),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: SliverReorderableList(
              itemCount: _queue.length,
              itemBuilder: (context, index) {
                final mediaItem = _queue[index];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(mediaItem.id),
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: PlayPauseGestureDetectorMediaitem(
                      mediaItem: mediaItem,
                      child: MediaitemTile(mediaItem: mediaItem),
                    ),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) async {
                await _playerCubit.mtPlayerService
                    .reorderQueue(oldIndex, newIndex);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Expanded content shown in the [SliverAppBar]'s flexible space:
/// video, title, seek bar and playback controls.
class _ExpandedPlayer extends StatefulWidget {
  const _ExpandedPlayer({required this.playerCubit});

  final PlayerCubit playerCubit;

  @override
  State<_ExpandedPlayer> createState() => _ExpandedPlayerState();
}

class _ExpandedPlayerState extends State<_ExpandedPlayer> {
  /// The source controller from the engine — used only to detect changes.
  ChewieController? _sourceController;

  /// A cached copy with [showControls] = false and [autoPlay] = false.
  /// Recreated only when the engine swaps in a new controller (new track).
  ChewieController? _cachedController;

  bool _isLoading = false;

  StreamSubscription<MediaItem?>? _mediaItemSubscription;

  @override
  void initState() {
    super.initState();
    // Determina lo stato iniziale dal valore corrente del BehaviorSubject.
    _isLoading =
        widget.playerCubit.mtPlayerService.mediaItem.valueOrNull == null;
    _syncController();
    // Re-sync whenever the track changes so the thumbnail updates too.
    _mediaItemSubscription =
        widget.playerCubit.mtPlayerService.mediaItem.listen((item) {
      if (!mounted) return;
      if (item == null) {
        // Nuovo brano in caricamento: azzera il controller e mostra skeleton.
        setState(() {
          _isLoading = true;
          _cachedController?.dispose();
          _cachedController = null;
          _sourceController = null;
        });
      } else {
        setState(() => _isLoading = false);
        _syncController();
      }
    });
  }

  @override
  void dispose() {
    _mediaItemSubscription?.cancel();
    _cachedController?.dispose();
    super.dispose();
  }

  /// Compares the engine's current [ChewieController] reference to the cached
  /// one. If it changed (new track loaded), disposes the stale copy and creates
  /// a fresh one — without triggering autoPlay so playback state is preserved.
  void _syncController() {
    final source = widget.playerCubit.mtPlayerService.chewieController;
    if (source == _sourceController) return;
    setState(() {
      _cachedController?.dispose();
      _sourceController = source;
      _cachedController =
          source?.copyWith(showControls: false, autoPlay: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const CustomSkeletonExpandedPlayer();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Video + title/artist
              StreamBuilder(
                stream: widget.playerCubit.mtPlayerService.mediaItem,
                builder: (context, snapshot) {
                  final item = snapshot.data;
                  return Row(
                    children: [
                      Hero(
                        tag: 'video_image_or_player',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 72,
                            height: 72,
                            child: _cachedController == null
                                ? const ColoredBox(color: Colors.black)
                                : Chewie(controller: _cachedController!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item?.title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item?.album ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Seek bar with timings
              const SeekBar(showTimings: true),
              Controls()
            ],
          ),
        ),
      ],
    );
  }
}

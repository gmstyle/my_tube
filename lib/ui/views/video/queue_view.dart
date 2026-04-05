import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';
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
class _ExpandedPlayer extends StatelessWidget {
  const _ExpandedPlayer({required this.playerCubit});

  final PlayerCubit playerCubit;

  @override
  Widget build(BuildContext context) {
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
                stream: playerCubit.mtPlayerService.mediaItem,
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
                            child: Builder(builder: (context) {
                              final chewie =
                                  playerCubit.mtPlayerService.chewieController;
                              if (chewie == null) {
                                return const ColoredBox(color: Colors.black);
                              }
                              return Chewie(
                                controller:
                                    chewie.copyWith(showControls: false),
                              );
                            }),
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

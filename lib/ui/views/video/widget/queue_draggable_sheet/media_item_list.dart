import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/video/widget/mediaitem_tile.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/play_pause_gesture_detector_mediaitem.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

class MediaItemList extends StatefulWidget {
  const MediaItemList({super.key});

  @override
  State<MediaItemList> createState() => _MediaItemListState();
}

class _MediaItemListState extends State<MediaItemList> {
  final ScrollController _scrollController = ScrollController();
  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
  }

  void _scrollToCurrentItem() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent <= 0) return;

    final playerCubit = context.read<PlayerCubit>();
    final currentIndex =
        playerCubit.mtPlayerService.playbackState.value.queueIndex;
    if (currentIndex == null || currentIndex < 0) return;

    final isExpanded = AppBreakpoints.isExpanded(context);
    // thumbnail height + inner padding (top+bottom) + outer Padding(vertical: 4) * 2
    final itemHeight = isExpanded
        ? (160.0 * 9 / 16) + 20.0 + 8.0 // ≈ 118.0
        : (120.0 * 9 / 16) + 16.0 + 8.0; // ≈ 91.5

    final viewportHeight = _scrollController.position.viewportDimension;
    final maxScroll = _scrollController.position.maxScrollExtent;

    final targetOffset =
        (currentIndex * itemHeight) - (viewportHeight / 2) + (itemHeight / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<PlayerCubit>();
    return StreamBuilder<List<MediaItem>>(
        stream: playerCubit.mtPlayerService.queue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final queue = snapshot.data!;
            if (!_initialScrollDone) {
              _initialScrollDone = true;
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scrollToCurrentItem());
            }
            return ReorderableListView.builder(
              scrollController: _scrollController,
              itemCount: queue.length,
              itemBuilder: (context, index) {
                final mediaItem = queue[index];
                return Padding(
                    key: Key(mediaItem.id),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: PlayPauseGestureDetectorMediaitem(
                        mediaItem: mediaItem,
                        child: MediaitemTile(
                            mediaItem: mediaItem,
                            darkBackground:
                                AppBreakpoints.isExpanded(context))));
              },
              onReorder: (int oldIndex, int newIndex) async {
                await playerCubit.mtPlayerService
                    .reorderQueue(oldIndex, newIndex);
              },
            );
          } else {
            return const SizedBox();
          }
        });
  }
}

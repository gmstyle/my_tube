import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/video_view/widget/mediaitem_tile.dart';
import 'package:my_tube/ui/views/video_view/widget/queue_draggable_sheet/play_pause_gesture_detector_mediaitem.dart';

class MediaItemList extends StatelessWidget {
  const MediaItemList({super.key});

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<PlayerCubit>();
    return Positioned(
      top: 40,
      bottom: 0,
      left: 0,
      right: 0,
      child: StreamBuilder<List<MediaItem>>(
          stream: playerCubit.mtPlayerService.queue,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final queue = snapshot.data!;
              return ReorderableListView.builder(
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  final mediaItem = queue[index];
                  return PlayPauseGestureDetectorMediaitem(
                      key: Key(mediaItem.id),
                      mediaItem: mediaItem,
                      child: MediaitemTile(mediaItem: mediaItem));
                },
                onReorder: (int oldIndex, int newIndex) async {
                  await playerCubit.mtPlayerService
                      .reorderQueue(oldIndex, newIndex);
                },
              );
            } else {
              return const SizedBox();
            }
          }),
    );
  }
}

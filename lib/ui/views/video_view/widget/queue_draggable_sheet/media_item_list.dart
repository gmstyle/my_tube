import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/views/video_view/widget/mediaitem_tile.dart';

class MediaItemList extends StatelessWidget {
  const MediaItemList({super.key});

  @override
  Widget build(BuildContext context) {
    final miniPlayerCubit = context.read<MiniPlayerCubit>();
    return Positioned(
      top: 40,
      bottom: 0,
      left: 0,
      right: 0,
      child: StreamBuilder<List<MediaItem>>(
          stream: miniPlayerCubit.mtPlayerService.queue,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final queue = snapshot.data!;
              return ReorderableListView.builder(
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  final mediaItem = queue[index];
                  return GestureDetector(
                      key: Key(mediaItem.id),
                      onTap: () {
                        if (miniPlayerCubit.mtPlayerService.currentTrack?.id !=
                            mediaItem.id) {
                          miniPlayerCubit.startPlaying(mediaItem.id);
                        }
                      },
                      child: MediaitemTile(mediaItem: mediaItem));
                },
                onReorder: (int oldIndex, int newIndex) async {
                  await miniPlayerCubit.mtPlayerService
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/respositories/queue_repository.dart';
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:my_tube/ui/views/common/resource_tile.dart';

class QueueTabView extends StatelessWidget {
  const QueueTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final miniplayerCubit = context.read<MiniPlayerCubit>();
    final queueRepository = context.read<QueueRepository>();

    return ValueListenableBuilder(
        valueListenable: queueRepository.queueListenable,
        builder: (context, box, _) {
          final queue = box.values.toList();

          final videoIds = queue.map((e) => e.id!).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(
                      'Your queue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const Spacer(),
                    /* IconButton(
                        color: Colors.white,
                        onPressed: queue.isNotEmpty
                            ? () {
                                miniplayerCubit.startPlayingPlaylist(videoIds);
                              }
                            : null,
                        icon: const Icon(Icons.playlist_play)), */
                    IconButton(
                        color: Colors.white,
                        onPressed: queue.isNotEmpty
                            ? () async {
                                await miniplayerCubit.mtPlayerHandler
                                    .clearQueue();
                              }
                            : null,
                        icon: const Icon(Icons.clear_all_rounded))
                  ],
                ),
              ),
              Expanded(
                child: queue.isNotEmpty
                    ? ListView.builder(
                        itemCount: queue.length,
                        itemBuilder: (context, index) {
                          final video = queue[index];
                          return GestureDetector(
                              onTap: () async {
                                await context
                                    .read<MiniPlayerCubit>()
                                    .startPlaying(video.id!);
                              },
                              child: ResourceTile(resource: video));
                        },
                      )
                    : const Center(child: Text('Queue is empty')),
              ),
            ],
          );
        });
  }
}

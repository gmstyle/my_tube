import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_bloc.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class QueueTabView extends StatelessWidget {
  const QueueTabView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FavoritesBloc>().add(GetFavorites());
    return BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
      switch (state.status) {
        case FavoritesStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case FavoritesStatus.success:
          final queue = state.favorites!;
          final videoIds = queue.map((e) => e.id!).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(
                      'Your fvorites',
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
                            ? () {
                                context
                                    .read<FavoritesBloc>()
                                    .add(ClearFavorites());
                              }
                            : null,
                        icon: const Icon(Icons.clear_all_rounded))
                  ],
                ),
              ),
              Expanded(
                child: queue.isNotEmpty
                    ? ListView.builder(
                        //reverse: true,
                        itemCount: queue.length,
                        itemBuilder: (context, index) {
                          final video = queue[index];
                          return GestureDetector(
                              onTap: () async {
                                await context
                                    .read<MiniPlayerCubit>()
                                    .startPlaying(video.id!);
                              },
                              child: VideoTile(video: video));
                        },
                      )
                    : const Center(child: Text('Queue is empty')),
              ),
            ],
          );
        case FavoritesStatus.failure:
          return Center(child: Text(state.error!));
        default:
          return const SizedBox.shrink();
      }
    });

    /* return ValueListenableBuilder(
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
        }); */
  }
}

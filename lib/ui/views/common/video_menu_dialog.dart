import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';

class VideoMenuDialog extends StatelessWidget {
  const VideoMenuDialog({super.key, required this.video, required this.child});
  final ResourceMT video;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final favoritesBloc = context.read<FavoritesBloc>();

    final MiniPlayerCubit miniPlayerCubit =
        BlocProvider.of<MiniPlayerCubit>(context);
    return GestureDetector(
      onLongPress: () {
        // show option dialog
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                //title: const Text('Options'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // show the option to remove the video from the favorites if it is in the favorites
                    if (favoritesBloc.favoritesRepository.videoIds
                        .contains(video.id))
                      ListTile(
                        leading: const Icon(Icons.remove),
                        title: const Text('Remove from favorites'),
                        onTap: () {
                          favoritesBloc.add(RemoveFromFavorites(video.id!));
                          context.pop();
                        },
                      ),

                    // show the option to add the video to the favorites if it is not in the favorites
                    if (!favoritesBloc.favoritesRepository.videoIds
                        .contains(video.id))
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: const Text('Add to favorites'),
                        onTap: () {
                          favoritesBloc.add(AddToFavorites(video));
                          context.pop();
                        },
                      ),

                    // show the option to add the video to the queue if it is not in the queue
                    if (!miniPlayerCubit.mtPlayerService.queue.value
                        .map((e) => e.id)
                        .contains(video.id))
                      ListTile(
                        leading: const Icon(Icons.playlist_add),
                        title: const Text('Add to queue'),
                        onTap: () {
                          miniPlayerCubit.addToQueue(video.id!);
                          context.pop();
                        },
                      ),

                    // show the option to remove the video from the queue if it is in the queue
                    if (miniPlayerCubit.mtPlayerService.queue.value
                        .map((e) => e.id)
                        .contains(video.id))
                      ListTile(
                        leading: const Icon(Icons.remove),
                        title: const Text('Remove from queue'),
                        onTap: () {
                          miniPlayerCubit.removeFromQueue(video.id!);
                          context.pop();
                        },
                      ),
                  ],
                ),
              );
            });
      },
      child: child,
    );
  }
}

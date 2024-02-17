import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/download_service.dart';

class VideoMenuDialog extends StatelessWidget {
  const VideoMenuDialog({super.key, required this.video, required this.child});
  final ResourceMT video;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final favoritesBloc = context.read<FavoritesBloc>();
    final playerCubit = context.read<PlayerCubit>();
    final downloadService = context.read<DownloadService>();

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
                          favoritesBloc.add(
                              RemoveFromFavorites(video.id!, kind: 'video'));
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
                          favoritesBloc
                              .add(AddToFavorites(video, kind: 'video'));
                          context.pop();
                        },
                      ),

                    // show the option to add the video to the queue if it is not in the queue
                    if (!playerCubit.mtPlayerService.queue.value
                        .map((e) => e.id)
                        .contains(video.id))
                      ListTile(
                        leading: const Icon(Icons.playlist_add),
                        title: const Text('Add to queue'),
                        onTap: () {
                          playerCubit.addToQueue(video.id!);
                          context.pop();
                        },
                      ),

                    // show the option to remove the video from the queue if it is in the queue
                    if (playerCubit.mtPlayerService.queue.value
                        .map((e) => e.id)
                        .contains(video.id))
                      ListTile(
                        leading: const Icon(Icons.remove),
                        title: const Text('Remove from queue'),
                        onTap: () {
                          playerCubit.removeFromQueue(video.id!);
                          context.pop();
                        },
                      ),

                    // show the option to download the video
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Download'),
                      onTap: () async {
                        await downloadService.download(
                            video: video, context: context, isAudioOnly: false);
                      },
                    ),

                    // show the option to download the audio only
                    ListTile(
                      leading: const Icon(Icons.music_note),
                      title: const Text('Download audio only'),
                      onTap: () async {
                        await downloadService.download(
                            video: video, context: context, isAudioOnly: true);
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

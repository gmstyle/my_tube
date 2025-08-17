import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/services/download_service.dart';

class VideoMenuDialog extends StatelessWidget {
  const VideoMenuDialog(
      {super.key, required this.quickVideo, required this.child});
  final Map<String, String> quickVideo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final favoritesVideoBloc = context.read<FavoritesVideoBloc>();
    final playerCubit = context.read<PlayerCubit>();
    final downloadService = context.read<DownloadService>();

    final id = quickVideo['id']!;
    final title = quickVideo['title']!;

    return GestureDetector(
      onLongPress: () {
        // show option dialog
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                //title: const Text('Options'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // show the option to remove the video from the favorites if it is in the favorites
                    if (favoritesVideoBloc.favoritesRepository.videoIds
                        .contains(id))
                      ListTile(
                        leading: const Icon(Icons.remove),
                        title: const Text('Remove from favorites'),
                        onTap: () {
                          favoritesVideoBloc.add(RemoveFromFavorites(id));
                          Navigator.of(context).pop();
                        },
                      ),

                    // show the option to add the video to the favorites if it is not in the favorites
                    if (!favoritesVideoBloc.favoritesRepository.videoIds
                        .contains(id))
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: const Text('Add to favorites'),
                        onTap: () {
                          favoritesVideoBloc.add(AddToFavorites(id));
                          Navigator.of(context).pop();
                        },
                      ),

                    // show the option to add the video to the queue if it is not in the queue
                    if (!playerCubit.mtPlayerService.queue.value
                        .map((e) => e.id)
                        .contains(id))
                      ListTile(
                        leading: const Icon(Icons.playlist_add),
                        title: const Text('Add to queue'),
                        onTap: () {
                          playerCubit.addToQueue(id);
                          Navigator.of(context).pop();
                        },
                      ),

                    // show the option to remove the video from the queue if it is in the queue
                    if (playerCubit.mtPlayerService.queue.value
                        .map((e) => e.id)
                        .contains(id))
                      ListTile(
                        leading: const Icon(Icons.remove),
                        title: const Text('Remove from queue'),
                        onTap: () {
                          playerCubit.removeFromQueue(id);
                          Navigator.of(context).pop();
                        },
                      ),

                    // show the option to download the video
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Download'),
                      onTap: () {
                        downloadService.download(videos: [
                          {'id': id, 'title': title}
                        ], context: context);
                        Navigator.of(context).pop();
                      },
                    ),

                    // show the option to download the audio only
                    ListTile(
                      leading: const Icon(Icons.music_note),
                      title: const Text('Download audio only'),
                      onTap: () {
                        downloadService.download(videos: [
                          {'id': id, 'title': title}
                        ], context: context, isAudioOnly: true);
                        Navigator.of(context).pop();
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

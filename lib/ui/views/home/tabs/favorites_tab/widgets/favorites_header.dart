import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';

class FavoritesHeader extends StatelessWidget {
  const FavoritesHeader({
    super.key,
    required this.title,
    required this.ids,
  });

  final String title;
  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    final PlayerCubit miniplayerCubit = context.read<PlayerCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(
            Icons.favorite,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          if (ids.isNotEmpty) ...[
            const Spacer(),
            if (title == 'Videos')
              IconButton(
                  color: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () {
                    miniplayerCubit.startPlayingPlaylist(
                      ids,
                    );
                  },
                  icon: const Icon(Icons.playlist_play)),
            IconButton(
                color: Theme.of(context).colorScheme.onPrimary,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Icon(Icons.favorite,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer),
                              const SizedBox(width: 8),
                              const Text('Clear favorites'),
                            ],
                          ),
                          content: Text(
                              'Are you sure you want to clear your favorite ${title.toLowerCase()}?'),
                          actions: [
                            IconButton(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                                onPressed: () {
                                  context.pop();
                                },
                                icon: const Icon(
                                  Icons.close,
                                )),
                            IconButton(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                                onPressed: () {
                                  if (title == 'Videos') {
                                    context
                                        .read<FavoritesVideoBloc>()
                                        .add(const ClearFavorites());
                                  } else if (title == 'Channels') {
                                    context
                                        .read<FavoritesChannelBloc>()
                                        .add(const ClearFavoritesChannel());
                                  } else {
                                    context
                                        .read<FavoritesPlaylistBloc>()
                                        .add(const ClearFavoritesPlaylist());
                                  }

                                  context.pop();
                                },
                                icon: const Icon(
                                  Icons.check,
                                )),
                          ],
                        );
                      });
                },
                icon: const Icon(Icons.clear))
          ]
        ],
      ),
    );
  }
}

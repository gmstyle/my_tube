import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';

class FavoritesHeader extends StatelessWidget {
  const FavoritesHeader({
    super.key,
    required this.favorites,
  });

  final List<ResourceMT> favorites;

  @override
  Widget build(BuildContext context) {
    final PlayerCubit miniplayerCubit = context.read<PlayerCubit>();
    return Row(
      children: [
        Icon(
          Icons.favorite,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        const SizedBox(width: 8),
        Text(
          'Your favorites',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        if (favorites.isNotEmpty) ...[
          const Spacer(),
          IconButton(
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                miniplayerCubit.startPlayingPlaylist(favorites,
                    renewStreamUrls: true);
              },
              icon: const Icon(Icons.playlist_play)),
          IconButton(
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                showDialog<bool>(
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
                        content: const Text(
                            'Are you sure you want to clear your favorites?'),
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
                                context
                                    .read<FavoritesBloc>()
                                    .add(ClearFavorites());
                                context.pop();
                              },
                              icon: const Icon(
                                Icons.check,
                              )),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.clear_all_rounded))
        ]
      ],
    );
  }
}

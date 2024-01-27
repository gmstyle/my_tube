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
        const Icon(
          Icons.favorite,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Text(
          'Your favorites',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
        ),
        const Spacer(),
        IconButton(
            color: Colors.white,
            onPressed: favorites.isNotEmpty
                ? () {
                    miniplayerCubit.startPlayingPlaylist(favorites,
                        renewStreamUrls: true);
                  }
                : null,
            icon: const Icon(Icons.playlist_play)),
        IconButton(
            color: Colors.white,
            onPressed: favorites.isNotEmpty
                ? () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.favorite),
                                SizedBox(width: 8),
                                Text('Clear favorites'),
                              ],
                            ),
                            content: const Text(
                                'Are you sure you want to clear your favorites?'),
                            actions: [
                              IconButton(
                                  onPressed: () {
                                    context.pop(false);
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    context.pop(true);
                                  },
                                  icon: Icon(
                                    Icons.check,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )),
                            ],
                          );
                        }).then((value) {
                      if (value == true) {
                        context.read<FavoritesBloc>().add(ClearFavorites());
                      }
                    });
                  }
                : null,
            icon: const Icon(Icons.clear_all_rounded))
      ],
    );
  }
}

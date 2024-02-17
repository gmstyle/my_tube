import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_bloc.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/channel_playlist_menu_dialog.dart';
import 'package:my_tube/ui/views/common/playlist_tile.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/empty_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/favorites_header.dart';

class PlaylistFavorites extends StatelessWidget {
  const PlaylistFavorites({super.key, required this.favoritesBloc});

  final FavoritesBloc favoritesBloc;

  @override
  Widget build(BuildContext context) {
    favoritesBloc.add(const GetFavorites(kind: 'playlist'));

    return BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
      switch (state.status) {
        case FavoritesStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case FavoritesStatus.success:
          final favorites = state.resources!.reversed.toList();

          return Column(
            children: [
              FavoritesHeader(
                title: 'Playlists',
                favorites: favorites,
              ),
              Expanded(
                child: favorites.isNotEmpty
                    ? ListView.builder(
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final playlist = favorites[index];
                          return GestureDetector(
                            onTap: () {
                              context.goNamed(AppRoute.playlistFavorites.name,
                                  extra: {
                                    'playlist': playlist.title!,
                                    'playlistId': playlist.playlistId!
                                  });
                            },
                            child: ChannelPlaylistMenuDialog(
                                resource: playlist,
                                kind: 'playlist',
                                child: PlaylistTile(playlist: playlist)),
                          );
                        },
                      )
                    : const EmptyFavorites(
                        message: 'No favorite playlists yet',
                      ),
              ),
            ],
          );
        case FavoritesStatus.failure:
          return Center(child: Text(state.error!));
        default:
          return const SizedBox.shrink();
      }
    });
  }
}
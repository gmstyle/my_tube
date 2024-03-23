import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/channel_playlist_menu_dialog.dart';
import 'package:my_tube/ui/views/common/playlist_tile.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/empty_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/favorites_header.dart';

class PlaylistFavorites extends StatelessWidget {
  const PlaylistFavorites({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FavoritesPlaylistBloc>().add(const GetFavoritesPlaylist());

    return BlocBuilder<FavoritesPlaylistBloc, FavoritesPlaylistState>(
        builder: (context, state) {
      switch (state.status) {
        case FavoritesPlaylistStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case FavoritesPlaylistStatus.success:
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
        case FavoritesPlaylistStatus.failure:
          return Center(child: Text(state.error!));
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

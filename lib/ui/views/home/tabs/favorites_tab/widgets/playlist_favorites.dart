import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/channel_playlist_menu_dialog.dart';
import 'package:my_tube/ui/views/common/playlist_tile.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/empty_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/favorites_header.dart';
import 'package:my_tube/utils/enums.dart';

class PlaylistFavorites extends StatelessWidget {
  const PlaylistFavorites({super.key, required this.searchQuery});
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesPlaylistBloc, FavoritesPlaylistState>(
        builder: (context, state) {
      switch (state.status) {
        case FavoritesPlaylistStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case FavoritesPlaylistStatus.success:
          final favorites = state.playlists!
              .where((playlist) {
                final title = playlist.title.toLowerCase();
                final channelTitle = playlist.author?.toLowerCase() ?? '';
                final query = searchQuery.toLowerCase();
                return title.contains(query) || channelTitle.contains(query);
              })
              .toList()
              .reversed
              .toList();

          final List<String> ids =
              favorites.map((playlist) => playlist.id).toList();

          return Column(
            children: [
              FavoritesHeader(
                title: 'Playlists',
                ids: ids,
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
                                  extra: {'playlistId': playlist.id});
                            },
                            child: ChannelPlaylistMenuDialog(
                                id: playlist.id,
                                kind: Kind.playlist,
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

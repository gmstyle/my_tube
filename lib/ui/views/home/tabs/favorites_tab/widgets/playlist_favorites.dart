import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/router/app_navigator.dart';
import 'package:my_tube/ui/shared/responsive_layout_builder.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/channel_playlist_menu_dialog.dart';
import 'package:my_tube/ui/views/common/playlist_grid_item.dart';
import 'package:my_tube/ui/views/common/playlist_tile.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/empty_favorites.dart';
import 'package:my_tube/utils/enums.dart';

class PlaylistFavorites extends StatelessWidget {
  const PlaylistFavorites({
    super.key,
    required this.searchQuery,
    this.isTablet = false,
  });
  final String searchQuery;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesPlaylistBloc, FavoritesPlaylistState>(
        builder: (context, state) {
      switch (state.status) {
        case FavoritesPlaylistStatus.initial:
        case FavoritesPlaylistStatus.loading:
          return const CustomSkeletonGridList();
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

          return favorites.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: context.isCompact
                      ? ListView.separated(
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final playlist = favorites[index];
                            return GestureDetector(
                              onTap: () {
                                AppNavigator.pushPlaylist(context, playlist.id);
                              },
                              child: ChannelPlaylistMenuDialog(
                                  id: playlist.id,
                                  kind: Kind.playlist,
                                  child: PlaylistTile(playlist: playlist)),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isTablet ? 3 : 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 16 / 13,
                          ),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final playlist = favorites[index];
                            return PlaylistGridItem(
                              playlist: playlist,
                              onTap: () => AppNavigator.pushPlaylist(
                                  context, playlist.id),
                            );
                          },
                        ),
                )
              : const EmptyFavorites(
                  message: 'No favorite playlists yet',
                );
        case FavoritesPlaylistStatus.failure:
          return Center(child: Text(state.error!));
      }
    });
  }
}

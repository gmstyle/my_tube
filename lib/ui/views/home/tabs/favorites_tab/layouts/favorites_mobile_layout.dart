import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/favorites_search_delegate.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/favorites_tab_view.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/channel_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/custom_playlist_list.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/playlist_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/video_favorites.dart';

class FavoritesMobileLayout extends StatelessWidget {
  const FavoritesMobileLayout({
    super.key,
    required this.active,
    required this.onSelectCategory,
  });

  final FavoriteCategory active;
  final void Function(FavoriteCategory) onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          floating: true,
          snap: true,
          pinned: false,
          automaticallyImplyLeading: false,
          toolbarHeight: 48,
          forceElevated: innerBoxIsScrolled,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Text(
                  'Favorites',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                if (active == FavoriteCategory.videos)
                  IconButton(
                    onPressed: () => _playAllVideos(context),
                    icon: Icon(Icons.play_circle_outline, color: cs.onSurface),
                    tooltip: 'Play all',
                  ),
                IconButton(
                  onPressed: () async {
                    await showSearch(
                      context: context,
                      delegate: FavoritesSearchDelegate(),
                    );
                  },
                  icon: Icon(Icons.search, color: cs.onSurface),
                ),
                _buildMoreMenu(context),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Videos'),
                      selected: active == FavoriteCategory.videos,
                      onSelected: (_) =>
                          onSelectCategory(FavoriteCategory.videos),
                      showCheckmark: false,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Channels'),
                      selected: active == FavoriteCategory.channels,
                      onSelected: (_) =>
                          onSelectCategory(FavoriteCategory.channels),
                      showCheckmark: false,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Playlists'),
                      selected: active == FavoriteCategory.playlists,
                      onSelected: (_) =>
                          onSelectCategory(FavoriteCategory.playlists),
                      showCheckmark: false,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('My playlists'),
                      selected: active == FavoriteCategory.myPlaylists,
                      onSelected: (_) =>
                          onSelectCategory(FavoriteCategory.myPlaylists),
                      showCheckmark: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      body: Builder(builder: (context) {
        switch (active) {
          case FavoriteCategory.videos:
            return const VideoFavorites(searchQuery: '');
          case FavoriteCategory.channels:
            return const ChannelFavorites(searchQuery: '');
          case FavoriteCategory.playlists:
            return const PlaylistFavorites(searchQuery: '');
          case FavoriteCategory.myPlaylists:
            return const CustomPlaylistList();
        }
      }),
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon:
          Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
      onSelected: (value) {
        if (value == 'clear') _showClearDialog(context);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'clear',
          child: Row(
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 8),
              Text('Clear favorites'),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context) {
    final title = active == FavoriteCategory.videos
        ? 'Videos'
        : active == FavoriteCategory.channels
            ? 'Channels'
            : 'Playlists';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline,
                color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Clear favorites'),
          ],
        ),
        content: Text(
            'Are you sure you want to clear your favorite ${title.toLowerCase()}?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (active == FavoriteCategory.videos) {
                context.read<FavoritesVideoBloc>().add(const ClearFavorites());
              } else if (active == FavoriteCategory.channels) {
                context
                    .read<FavoritesChannelBloc>()
                    .add(const ClearFavoritesChannel());
              } else {
                context
                    .read<FavoritesPlaylistBloc>()
                    .add(const ClearFavoritesPlaylist());
              }
              ctx.pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _playAllVideos(BuildContext context) {
    final state = context.read<FavoritesVideoBloc>().state;
    if (state.status == FavoritesStatus.success &&
        state.videos != null &&
        state.videos!.isNotEmpty) {
      final ids = state.videos!.reversed.map((e) => e.id).toList();
      context.read<PlayerCubit>().startPlayingPlaylist(ids);
    }
  }
}

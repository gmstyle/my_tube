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

class FavoritesTabletLayout extends StatelessWidget {
  const FavoritesTabletLayout({
    super.key,
    required this.active,
    required this.onSelectCategory,
  });

  final FavoriteCategory active;
  final void Function(FavoriteCategory) onSelectCategory;

  static const double _sidebarWidth = 240.0;
  static const double _contentMaxWidth = 1200.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        // ── Top AppBar ──────────────────────────────────────────────────
        Material(
          color: cs.surface,
          elevation: 0,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 8),
                child: Row(
                  children: [
                    Text(
                      'Favorites',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (active == FavoriteCategory.videos)
                      IconButton(
                        onPressed: () => _playAllVideos(context),
                        icon: Icon(Icons.play_circle_outline,
                            color: cs.onSurface),
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
            ),
          ),
        ),

        const Divider(height: 1),

        // ── Body: sidebar + content ─────────────────────────────────────
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left sidebar ──────────────────────────────────────
                  SizedBox(
                    width: _sidebarWidth,
                    child: Material(
                      color: cs.surfaceContainerLow,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          _SidebarItem(
                            icon: Icons.video_library_outlined,
                            selectedIcon: Icons.video_library,
                            label: 'Videos',
                            selected: active == FavoriteCategory.videos,
                            onTap: () =>
                                onSelectCategory(FavoriteCategory.videos),
                          ),
                          _SidebarItem(
                            icon: Icons.people_outline,
                            selectedIcon: Icons.people,
                            label: 'Channels',
                            selected: active == FavoriteCategory.channels,
                            onTap: () =>
                                onSelectCategory(FavoriteCategory.channels),
                          ),
                          _SidebarItem(
                            icon: Icons.queue_music_outlined,
                            selectedIcon: Icons.queue_music,
                            label: 'Playlists',
                            selected: active == FavoriteCategory.playlists,
                            onTap: () =>
                                onSelectCategory(FavoriteCategory.playlists),
                          ),
                          _SidebarItem(
                            icon: Icons.playlist_add_check_outlined,
                            selectedIcon: Icons.playlist_add_check,
                            label: 'My playlists',
                            selected: active == FavoriteCategory.myPlaylists,
                            onTap: () =>
                                onSelectCategory(FavoriteCategory.myPlaylists),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1),

                  // ── Content panel ─────────────────────────────────────
                  Expanded(
                    child: switch (active) {
                      FavoriteCategory.videos =>
                        const VideoFavorites(searchQuery: '', isTablet: true),
                      FavoriteCategory.channels =>
                        const ChannelFavorites(searchQuery: '', isTablet: true),
                      FavoriteCategory.playlists => const PlaylistFavorites(
                          searchQuery: '', isTablet: true),
                      FavoriteCategory.myPlaylists =>
                        const CustomPlaylistList(),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

// ── Sidebar list item ──────────────────────────────────────────────────────

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? cs.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color:
                      selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected
                        ? cs.onSecondaryContainer
                        : cs.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

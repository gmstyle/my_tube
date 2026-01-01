import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';

import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/channel_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/playlist_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/video_favorites.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/favorites_search_delegate.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:go_router/go_router.dart';

class FavoritesTabView extends StatefulWidget {
  const FavoritesTabView({super.key});

  @override
  State<FavoritesTabView> createState() => _FavoritesTabViewState();
}

class _FavoritesTabViewState extends State<FavoritesTabView> {
  // active chip selection (exclusive)
  FavoriteCategory _active = FavoriteCategory.videos;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    context.read<FavoritesVideoBloc>().add(const GetFavorites());
    context.read<FavoritesChannelBloc>().add(const GetFavoritesChannel());
    context.read<FavoritesPlaylistBloc>().add(const GetFavoritesPlaylist());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header Row (Standardized)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Text(
                  'Favorites',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    await showSearch(
                      context: context,
                      delegate: FavoritesSearchDelegate(),
                    );
                  },
                  icon: Icon(Icons.search,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
                _buildMoreMenu(context),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ChoiceChip(
                  label: const Text('Videos'),
                  selected: _active == FavoriteCategory.videos,
                  onSelected: (s) =>
                      setState(() => _active = FavoriteCategory.videos),
                  showCheckmark: false,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Channels'),
                  selected: _active == FavoriteCategory.channels,
                  onSelected: (s) =>
                      setState(() => _active = FavoriteCategory.channels),
                  showCheckmark: false,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Playlists'),
                  selected: _active == FavoriteCategory.playlists,
                  onSelected: (s) =>
                      setState(() => _active = FavoriteCategory.playlists),
                  showCheckmark: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.reverse) {
                  if (_isFabVisible) setState(() => _isFabVisible = false);
                } else if (notification.direction == ScrollDirection.forward) {
                  if (!_isFabVisible) setState(() => _isFabVisible = true);
                }
                return true;
              },
              child: Builder(builder: (context) {
                switch (_active) {
                  case FavoriteCategory.videos:
                    return const VideoFavorites(searchQuery: '');
                  case FavoriteCategory.channels:
                    return const ChannelFavorites(searchQuery: '');
                  case FavoriteCategory.playlists:
                    return const PlaylistFavorites(searchQuery: '');
                }
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: _active == FavoriteCategory.videos
          ? AnimatedScale(
              scale: _isFabVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton(
                onPressed: _playAllVideos,
                child: const Icon(Icons.play_arrow),
              ),
            )
          : null,
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon:
          Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
      onSelected: (value) {
        if (value == 'clear') {
          _showClearDialog(context);
        }
      },
      itemBuilder: (context) => [
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
    final title = _active == FavoriteCategory.videos
        ? 'Videos'
        : _active == FavoriteCategory.channels
            ? 'Channels'
            : 'Playlists';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Clear favorites'),
            ],
          ),
          content: Text(
              'Are you sure you want to clear your favorite ${title.toLowerCase()}?'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_active == FavoriteCategory.videos) {
                  context
                      .read<FavoritesVideoBloc>()
                      .add(const ClearFavorites());
                } else if (_active == FavoriteCategory.channels) {
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
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _playAllVideos() {
    final state = context.read<FavoritesVideoBloc>().state;
    if (state.status == FavoritesStatus.success &&
        state.videos != null &&
        state.videos!.isNotEmpty) {
      // Respect the logic in VideoFavorites which effectively plays them in reverse order (newest first I assume?)
      // VideoFavorites: .reversed.toList()
      final ids = state.videos!.reversed.map((e) => e.id).toList();
      context.read<PlayerCubit>().startPlayingPlaylist(ids);
    }
  }
}

enum FavoriteCategory { videos, channels, playlists }

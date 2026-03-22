import 'package:flutter/material.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';

import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/channel_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/playlist_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/video_favorites.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/favorites_search_delegate.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/custom_playlist_list.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<FavoritesVideoBloc>().add(const GetFavorites());
    context.read<FavoritesChannelBloc>().add(const GetFavoritesChannel());
    context.read<FavoritesPlaylistBloc>().add(const GetFavoritesPlaylist());
    if (context.mounted) {
      context.read<PersistentUiCubit>().setNavBarVisibility(true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.only(
                    left: 16,
                    //right: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Favorites',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const Spacer(),
                      if (_active == FavoriteCategory.videos)
                        IconButton(
                          onPressed: _playAllVideos,
                          icon: Icon(Icons.play_circle_outline,
                              color: Theme.of(context).colorScheme.onSurface),
                          tooltip: 'Play all',
                        ),
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
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Videos'),
                            selected: _active == FavoriteCategory.videos,
                            onSelected: (s) => setState(
                                () => _active = FavoriteCategory.videos),
                            showCheckmark: false,
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Channels'),
                            selected: _active == FavoriteCategory.channels,
                            onSelected: (s) => setState(
                                () => _active = FavoriteCategory.channels),
                            showCheckmark: false,
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Playlists'),
                            selected: _active == FavoriteCategory.playlists,
                            onSelected: (s) => setState(
                                () => _active = FavoriteCategory.playlists),
                            showCheckmark: false,
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('My playlists'),
                            selected: _active == FavoriteCategory.myPlaylists,
                            onSelected: (s) => setState(
                                () => _active = FavoriteCategory.myPlaylists),
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
          switch (_active) {
            case FavoriteCategory.videos:
              return const VideoFavorites(searchQuery: '');
            case FavoriteCategory.channels:
              return const ChannelFavorites(searchQuery: '');
            case FavoriteCategory.playlists:
              return const PlaylistFavorites(searchQuery: '');
            case FavoriteCategory.myPlaylists:
              return const CustomPlaylistList();
          }
        }));
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

enum FavoriteCategory { videos, channels, playlists, myPlaylists }

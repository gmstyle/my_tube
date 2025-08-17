import 'package:flutter/material.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';

import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/channel_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/playlist_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/video_favorites.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/favorites_search_delegate.dart';

class FavoritesTabView extends StatefulWidget {
  const FavoritesTabView({super.key});

  @override
  State<FavoritesTabView> createState() => _FavoritesTabViewState();
}

class _FavoritesTabViewState extends State<FavoritesTabView> {
  final TextEditingController _searchController = TextEditingController();

  // active chip selection (exclusive)
  FavoriteCategory _active = FavoriteCategory.videos;

  @override
  void initState() {
    super.initState();
    context.read<FavoritesVideoBloc>().add(const GetFavorites());
    context.read<FavoritesChannelBloc>().add(const GetFavoritesChannel());
    context.read<FavoritesPlaylistBloc>().add(const GetFavoritesPlaylist());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // header row: search icon + title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () async {
                  await showSearch(
                    context: context,
                    delegate: FavoritesSearchDelegate(),
                  );
                },
                icon: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
              const SizedBox(width: 8),
              Text('Favorites',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      )),
            ],
          ),
        ),

        // Filter chips (exclusive selection)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Videos'),
                selected: _active == FavoriteCategory.videos,
                onSelected: (s) {
                  setState(() {
                    _active = FavoriteCategory.videos;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Channels'),
                selected: _active == FavoriteCategory.channels,
                onSelected: (s) {
                  setState(() {
                    _active = FavoriteCategory.channels;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Playlists'),
                selected: _active == FavoriteCategory.playlists,
                onSelected: (s) {
                  setState(() {
                    _active = FavoriteCategory.playlists;
                  });
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // content area (bottom inset now handled by ScaffoldWithNavbar)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
    );
  }
}

enum FavoriteCategory { videos, channels, playlists }

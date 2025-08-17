import 'package:flutter/material.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';

import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/channel_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/playlist_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/video_favorites.dart';
import 'package:provider/provider.dart';

class FavoritesTabView extends StatefulWidget {
  const FavoritesTabView({super.key});

  @override
  State<FavoritesTabView> createState() => _FavoritesTabViewState();
}

class _FavoritesTabViewState extends State<FavoritesTabView> {
  final TextEditingController _searchController = TextEditingController();

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
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).colorScheme.primaryContainer,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    });
                  },
                ),
                hintText: 'Search for favorites videos, channels, playlists',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
              onChanged: (query) {
                setState(() {});
              },
            ),
          ),
          TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Theme.of(context).colorScheme.onPrimary,
              tabs: [
                // favorites videos
                Tab(
                  icon: Icon(
                    Icons.video_library,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                // favorites channels
                Tab(
                  icon: Icon(Icons.people,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
                // favorites playlists
                Tab(
                  icon: Icon(Icons.queue_play_next,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ]),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                VideoFavorites(searchQuery: _searchController.text),
                ChannelFavorites(searchQuery: _searchController.text),
                PlaylistFavorites(
                  searchQuery: _searchController.text,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

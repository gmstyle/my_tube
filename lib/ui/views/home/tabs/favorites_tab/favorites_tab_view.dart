import 'package:flutter/material.dart';

import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/channel_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/playlist_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/video_favorites.dart';

class FavoritesTabView extends StatefulWidget {
  const FavoritesTabView({super.key});

  @override
  State<FavoritesTabView> createState() => _FavoritesTabViewState();
}

class _FavoritesTabViewState extends State<FavoritesTabView> {
  final TextEditingController _searchController = TextEditingController();

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
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search favorites...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (query) {
              setState(() {});
            },
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
                  icon: Icon(Icons.album,
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

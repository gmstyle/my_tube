import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/models/playlist_mt.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/playlist_grid_item.dart';

class PlaylistSection extends StatelessWidget {
  const PlaylistSection({super.key, required this.playlists});

  final List<PlaylistMT> playlists;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GridView.custom(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: 8,
                maxCrossAxisExtent: MediaQuery.of(context).size.width - 32),
            childrenDelegate: SliverChildBuilderDelegate((context, index) {
              final playlist = playlists[index];
              return GestureDetector(
                child: PlaylistGridItem(playlist: playlist),
                onTap: () {
                  context.pushNamed(AppRoute.playlist.name,
                      extra: {'playlistId': playlist.id});
                },
              );
            }, childCount: playlists.length)));
  }
}

import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/router/app_navigator.dart';
import 'package:my_tube/ui/views/common/playlist_grid_item.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

/// Sliver with a horizontal row of playlist cards.
class MusicFeaturedPlaylistsSection extends StatelessWidget {
  const MusicFeaturedPlaylistsSection({super.key, required this.playlists});

  final List<models.PlaylistTile> playlists;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: isCompact ? 180 : 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: playlists.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return PlaylistGridItem(
              playlist: playlist,
              onTap: () => AppNavigator.pushPlaylist(context, playlist.id),
            );
          },
        ),
      ),
    );
  }
}

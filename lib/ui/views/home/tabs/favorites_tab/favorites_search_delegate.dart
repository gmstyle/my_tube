import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/ui/views/common/channel_tile.dart';
import 'package:my_tube/ui/views/common/playlist_tile.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/empty_favorites.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/channel_playlist_menu_dialog.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/utils/enums.dart';

class FavoritesSearchDelegate extends SearchDelegate<void> {
  FavoritesSearchDelegate();

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.primaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimaryContainer),
        actionsIconTheme:
            IconThemeData(color: theme.colorScheme.onPrimaryContainer),
      ),
      scaffoldBackgroundColor: Colors.transparent,
      hintColor: theme.colorScheme.onPrimary,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: theme.colorScheme.onPrimaryContainer,
        selectionColor:
            theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: theme.colorScheme.onPrimaryContainer),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
      ),
    );
  }

  // Helper to search current favorites from blocs
  // Return grouped model matches for each category
  Map<String, List<dynamic>> _groupedMatches(
      BuildContext context, String query) {
    final q = query.toLowerCase();
    final Map<String, List<dynamic>> grouped = {
      'videos': [],
      'channels': [],
      'playlists': [],
    };

    final videoState = context.read<FavoritesVideoBloc>().state;
    if (videoState.status == FavoritesStatus.success &&
        videoState.videos != null) {
      grouped['videos'] = videoState.videos!
          .where((v) {
            final title = v.title.toLowerCase();
            final artist = v.artist?.toLowerCase() ?? '';
            return title.contains(q) || artist.contains(q);
          })
          .toList()
          .reversed
          .toList();
    }

    final channelState = context.read<FavoritesChannelBloc>().state;
    if (channelState.status == FavoritesChannelStatus.success &&
        channelState.channels != null) {
      grouped['channels'] = channelState.channels!
          .where((c) => c.title.toLowerCase().contains(q))
          .toList()
          .reversed
          .toList();
    }

    final playlistState = context.read<FavoritesPlaylistBloc>().state;
    if (playlistState.status == FavoritesPlaylistStatus.success &&
        playlistState.playlists != null) {
      grouped['playlists'] = playlistState.playlists!
          .where((p) {
            final title = p.title.toLowerCase();
            final author = p.author?.toLowerCase() ?? '';
            return title.contains(q) || author.contains(q);
          })
          .toList()
          .reversed
          .toList();
    }

    return grouped;
  }

  Widget _sectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
      child: Row(
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Text('$count', style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      ),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
      ];
    }
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    final grouped = _groupedMatches(context, query);
    final total = grouped.values.fold<int>(0, (p, e) => p + e.length);

    final parentTheme = Theme.of(context);
    final fixedTheme = parentTheme.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
    );

    if (total == 0) {
      return Theme(
        data: fixedTheme,
        child: MainGradient(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off,
                    size: 64, color: parentTheme.colorScheme.onPrimary),
                const SizedBox(height: 12),
                Text('No results',
                    style: parentTheme.textTheme.titleMedium
                        ?.copyWith(color: parentTheme.colorScheme.onPrimary)),
                const SizedBox(height: 6),
                Text('Try a different query or clear filters',
                    style: parentTheme.textTheme.bodySmall
                        ?.copyWith(color: parentTheme.colorScheme.onPrimary)),
              ],
            ),
          ),
        ),
      );
    }

    return Theme(
      data: fixedTheme,
      child: MainGradient(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            if (grouped['videos']!.isNotEmpty) ...[
              _sectionHeader(context, 'Videos', grouped['videos']!.length),
              ...grouped['videos']!.map((video) {
                final quickVideo = <String, String>{
                  'id': video.id,
                  'title': video.title
                };
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: PlayPauseGestureDetector(
                    id: video.id,
                    child: VideoMenuDialog(
                        quickVideo: quickVideo, child: VideoTile(video: video)),
                  ),
                );
              }),
            ],
            if (grouped['channels']!.isNotEmpty) ...[
              _sectionHeader(context, 'Channels', grouped['channels']!.length),
              ...grouped['channels']!.map((ch) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ChannelPlaylistMenuDialog(
                      id: ch.id,
                      kind: Kind.channel,
                      child: ChannelTile(channel: ch)),
                );
              }),
            ],
            if (grouped['playlists']!.isNotEmpty) ...[
              _sectionHeader(
                  context, 'Playlists', grouped['playlists']!.length),
              ...grouped['playlists']!.map((pl) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ChannelPlaylistMenuDialog(
                      id: pl.id,
                      kind: Kind.playlist,
                      child: PlaylistTile(playlist: pl)),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      // show quick suggestion chips based on favorites counts
      final videoState = context.read<FavoritesVideoBloc>().state;
      final channelState = context.read<FavoritesChannelBloc>().state;
      final playlistState = context.read<FavoritesPlaylistBloc>().state;

      final examples = <String>[];
      if (videoState.status == FavoritesStatus.success &&
          videoState.videos != null &&
          videoState.videos!.isNotEmpty) {
        examples.add(videoState.videos!.last.title);
      }
      if (channelState.status == FavoritesChannelStatus.success &&
          channelState.channels != null &&
          channelState.channels!.isNotEmpty) {
        examples.add(channelState.channels!.last.title);
      }
      if (playlistState.status == FavoritesPlaylistStatus.success &&
          playlistState.playlists != null &&
          playlistState.playlists!.isNotEmpty) {
        examples.add(playlistState.playlists!.last.title);
      }

      if (examples.isEmpty) {
        return const Center(
            child: EmptyFavorites(message: 'No favorites to suggest'));
      }

      return MainGradient(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: examples.map((e) {
              return ActionChip(
                label: Text(e, overflow: TextOverflow.ellipsis),
                onPressed: () {
                  query = e;
                  showResults(context);
                },
              );
            }).toList(),
          ),
        ),
      );
    }

    return buildResults(context);
  }
}

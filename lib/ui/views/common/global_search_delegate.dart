import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/channel_grid_item.dart';
import 'package:my_tube/ui/views/common/channel_playlist_menu_dialog.dart';
import 'package:my_tube/ui/views/common/channel_tile.dart';
import 'package:my_tube/ui/views/common/playlist_grid_item.dart';
import 'package:my_tube/ui/views/common/playlist_tile.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/utils/enums.dart';

class GlobalSearchDelegate extends SearchDelegate<void> {
  GlobalSearchDelegate();

  String _lastQuery = '';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        systemOverlayStyle: theme.appBarTheme.systemOverlayStyle,
      ),
      hintColor: theme.colorScheme.onSurfaceVariant,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: theme.colorScheme.primary,
        selectionColor: theme.colorScheme.primary.withValues(alpha: 0.5),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: theme.colorScheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
  @override
  Widget buildResults(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final parentTheme = Theme.of(context);

        switch (state.status) {
          case SearchStatus.loading:
            return const CustomSkeletonGridList();

          case SearchStatus.success:
            if (state.items == null || state.items!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off,
                        size: 64, color: parentTheme.colorScheme.onSurface),
                    const SizedBox(height: 12),
                    Text('No results found',
                        style: parentTheme.textTheme.titleMedium?.copyWith(
                            color: parentTheme.colorScheme.onSurface)),
                    const SizedBox(height: 6),
                    Text('Try a different search term',
                        style: parentTheme.textTheme.bodySmall?.copyWith(
                            color: parentTheme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              );
            }

            return _buildUnifiedResults(context, state.items!, state);

          case SearchStatus.failure:
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: parentTheme.colorScheme.onSurface),
                  const SizedBox(height: 12),
                  Text('Search failed',
                      style: parentTheme.textTheme.titleMedium
                          ?.copyWith(color: parentTheme.colorScheme.onSurface)),
                  const SizedBox(height: 6),
                  Text(state.error ?? 'Unknown error occurred',
                      style: parentTheme.textTheme.bodySmall?.copyWith(
                          color: parentTheme.colorScheme.onSurfaceVariant)),
                ],
              ),
            );

          default:
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search,
                      size: 64, color: parentTheme.colorScheme.onSurface),
                  const SizedBox(height: 12),
                  Text('Search for videos, channels, and playlists',
                      style: parentTheme.textTheme.titleMedium
                          ?.copyWith(color: parentTheme.colorScheme.onSurface)),
                ],
              ),
            );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final parentTheme = Theme.of(context);

    if (query.isEmpty) {
      // Show search history as suggestion chips
      return BlocBuilder<SearchSuggestionCubit, SearchSuggestionState>(
        builder: (context, state) {
          // Load query history when widget is first built and state is empty
          if (state.suggestions.isEmpty && !state.isQueryHistory) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<SearchSuggestionCubit>().getQueryHistory();
            });
          }

          if (state.suggestions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history,
                      size: 64, color: parentTheme.colorScheme.onSurface),
                  const SizedBox(height: 12),
                  Text('No search history',
                      style: parentTheme.textTheme.titleMedium
                          ?.copyWith(color: parentTheme.colorScheme.onSurface)),
                  const SizedBox(height: 6),
                  Text('Your recent searches will appear here',
                      style: parentTheme.textTheme.bodySmall?.copyWith(
                          color: parentTheme.colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent searches',
                  style: parentTheme.textTheme.titleMedium?.copyWith(
                    color: parentTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion =
                          state.suggestions.reversed.toList()[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.history,
                          color: parentTheme.colorScheme.onSurface,
                          size: 20,
                        ),
                        title: Text(
                          suggestion,
                          style: TextStyle(
                            color: parentTheme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: parentTheme.colorScheme.onSurface,
                            size: 18,
                          ),
                          onPressed: () {
                            context
                                .read<SearchSuggestionCubit>()
                                .deleteQueryFromHistory(suggestion);
                          },
                        ),
                        onTap: () {
                          query = suggestion;
                          _performSearch(context);
                          showResults(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Show live search suggestions
      return BlocBuilder<SearchSuggestionCubit, SearchSuggestionState>(
        builder: (context, state) {
          // Only fetch suggestions if query has changed
          if (query != _lastQuery && query.isNotEmpty) {
            _lastQuery = query;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<SearchSuggestionCubit>().getSuggestions(query);
            });
          }

          if ((state.suggestions.isEmpty && !state.isQueryHistory) ||
              query != _lastQuery) {
            return Center(
              child: CircularProgressIndicator(
                color: parentTheme.colorScheme.primary,
              ),
            );
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggestions',
                  style: parentTheme.textTheme.titleMedium?.copyWith(
                    color: parentTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = state.suggestions[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.search,
                          color: parentTheme.colorScheme.onSurface,
                          size: 20,
                        ),
                        title: Text(
                          suggestion,
                          style: TextStyle(
                            color: parentTheme.colorScheme.onSurface,
                          ),
                        ),
                        onTap: () {
                          query = suggestion;
                          _performSearch(context);
                          showResults(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildUnifiedResults(
      BuildContext context, List<dynamic> items, SearchState state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          final maxScroll = notification.metrics.maxScrollExtent;
          final current = notification.metrics.pixels;
          if (maxScroll - current < 300) {
            context.read<SearchBloc>().add(const LoadMoreSearchContents());
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        itemCount: items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            // Loading indicator at the end
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: _buildItemTile(context, item),
          );
        },
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, dynamic item) {
    if (item is models.VideoTile) {
      return _buildVideoTile(context, item, false);
    } else if (item is models.ChannelTile) {
      return _buildChannelTile(context, item, false);
    } else if (item is models.PlaylistTile) {
      return _buildPlaylistTile(context, item, false);
    }
    return const SizedBox.shrink();
  }

  Widget _buildVideoTile(
      BuildContext context, models.VideoTile video, bool isTablet) {
    void handleTap() {
      close(context, null);
    }

    final quickVideo = {'id': video.id, 'title': video.title};
    return VideoMenuDialog(
      quickVideo: quickVideo,
      child: isTablet
          ? VideoGridItem(video: video, onTap: handleTap)
          : VideoTile(video: video, onTap: handleTap),
    );
  }

  Widget _buildChannelTile(
      BuildContext context, models.ChannelTile channel, bool isTablet) {
    void handleTap() {
      close(context, null);
      context.goNamed(AppRoute.channel.name, extra: {'channelId': channel.id});
    }

    return ChannelPlaylistMenuDialog(
      id: channel.id,
      kind: Kind.channel,
      child: isTablet
          ? ChannelGridItem(
              channel: channel,
              onTap: handleTap,
            )
          : ChannelTile(
              channel: channel,
              onTap: handleTap,
            ),
    );
  }

  Widget _buildPlaylistTile(
      BuildContext context, models.PlaylistTile playlist, bool isTablet) {
    void handleTap() {
      close(context, null);
      context
          .goNamed(AppRoute.playlist.name, extra: {'playlistId': playlist.id});
    }

    return ChannelPlaylistMenuDialog(
      id: playlist.id,
      kind: Kind.playlist,
      child: isTablet
          ? PlaylistGridItem(
              playlist: playlist,
              onTap: handleTap,
            )
          : PlaylistTile(
              playlist: playlist,
              onTap: handleTap,
            ),
    );
  }

  @override
  String get searchFieldLabel => 'Search videos, channels, playlists...';

  @override
  void showResults(BuildContext context) {
    _performSearch(context);
    super.showResults(context);
  }

  void _performSearch(BuildContext context) {
    if (query.isNotEmpty) {
      context.read<SearchBloc>().add(SearchContents(query: query));
      _saveQueryToHistory(context, query);
    }
  }

  void _saveQueryToHistory(BuildContext context, String searchQuery) {
    // Save the search query to history using the SearchSuggestionCubit
    final cubit = context.read<SearchSuggestionCubit>();
    final box = cubit.settingsBox;

    List<String> queryHistory = [];
    if (box.containsKey('queryHistory')) {
      final history = (box.get('queryHistory') as String);
      final decoded = (jsonDecode(history) as List<dynamic>);
      queryHistory = decoded.map((e) => e.toString()).toList();
    }

    // Remove the query if it already exists to avoid duplicates
    queryHistory.remove(searchQuery);
    // Add the new query at the beginning
    queryHistory.insert(0, searchQuery);

    // Keep only the last 20 searches
    if (queryHistory.length > 20) {
      queryHistory = queryHistory.take(20).toList();
    }

    // Save back to storage
    box.put('queryHistory', jsonEncode(queryHistory));
  }
}

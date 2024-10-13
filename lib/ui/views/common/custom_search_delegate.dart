import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/channel_tile.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/playlist_tile.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class CustomSearchDelegate extends SearchDelegate {
  final SearchBloc searchBloc;
  final SearchSuggestionCubit searchSuggestionCubit;
  final PlayerCubit playerCubit;

  CustomSearchDelegate(
      {required this.searchBloc,
      required this.searchSuggestionCubit,
      required this.playerCubit});

  // per cambiare il testo nella barra di ricerca
  @override
  String? get searchFieldLabel => 'Search in MyTube';

  // per cambiare il colore del testo nella barra di ricerca
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actionsIconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      hintColor: Theme.of(context).colorScheme.onPrimary,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Theme.of(context).colorScheme.onPrimary,
        selectionColor: Theme.of(context).colorScheme.onPrimary,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    // clear button
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // back button
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return MainGradient(
        child: Center(
          child: Text('No results',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        ),
      );
    }
    searchBloc.add(SearchContents(query: query));

    return MainGradient(
      child: BlocBuilder(
          bloc: searchBloc,
          builder: (_, SearchState state) {
            switch (state.status) {
              case SearchStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case SearchStatus.success:
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (state.result?.nextPageToken != null) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        searchBloc.add(GetNextPageSearchContents(
                            query: query,
                            nextPageToken: state.result!.nextPageToken!));
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                      itemCount: state.result!.resources.length,
                      itemBuilder: (context, index) {
                        final result = state.result!.resources[index];
                        return GestureDetector(
                          onTap: () {
                            close(context, result);
                            _playOrNavigateTo(result, playerCubit, context);
                          },
                          child: _setTile(result),
                        );
                      }),
                );
              case SearchStatus.failure:
                return Center(child: Text(state.error!));

              default:
                return Container();
            }
          }),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      searchSuggestionCubit.getQueryHistory();
    } else {
      searchSuggestionCubit.getSuggestions(query);
    }

    return MainGradient(
      child: BlocBuilder(
          bloc: searchSuggestionCubit,
          builder: (_, SearchSuggestionState state) {
            log('state.isQueryHistory: ${state.isQueryHistory} - state.suggestions: ${state.suggestions}');
            return ListView.builder(
                itemCount: state.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = state.suggestions[index];
                  return ListTile(
                    leading: Icon(
                      state.isQueryHistory ? Icons.history : Icons.search,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    title: Text(suggestion,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary)),
                    trailing: state.isQueryHistory
                        ? IconButton(
                            onPressed: () {
                              searchSuggestionCubit
                                  .deleteQueryFromHistory(suggestion);
                            },
                            icon: Icon(Icons.close,
                                color: Theme.of(context).colorScheme.onPrimary),
                          )
                        : null,
                    onTap: () {
                      query = suggestion;
                      showResults(context);
                    },
                  );
                });
          }),
    );
  }

  void _playOrNavigateTo(
      ResourceMT result, PlayerCubit playerCubit, BuildContext context) {
    if (result.kind == 'video') {
      if (playerCubit.mtPlayerService.mediaItem.value?.id != result.id) {
        playerCubit.startPlaying(result.id!);
      }
    }

    if (result.kind == 'channel') {
      context.pushNamed(AppRoute.channel.name,
          extra: {'channelId': result.channelId!});
    }

    if (result.kind == 'playlist') {
      context.pushNamed(AppRoute.playlist.name,
          extra: {'playlist': result.title!, 'playlistId': result.playlistId!});
    }
  }

  Widget _setTile(ResourceMT result) {
    if (result.kind == 'video') {
      return VideoMenuDialog(video: result, child: VideoTile(video: result));
    }

    if (result.kind == 'channel') {
      return ChannelTile(channel: result);
    }

    if (result.kind == 'playlist') {
      return PlaylistTile(playlist: result);
    }

    return Container();
  }
}

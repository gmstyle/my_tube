import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/resource_tile.dart';

class CustomSearchDelegate extends SearchDelegate {
  final SearchBloc searchBloc;
  final SearchSuggestionCubit searchSuggestionCubit;
  final MiniPlayerCubit miniPlayerCubit;

  CustomSearchDelegate(
      {required this.searchBloc,
      required this.searchSuggestionCubit,
      required this.miniPlayerCubit});

// per cambiare il testo nella barra di ricerca
  @override
  String? get searchFieldLabel => 'Search...';

// per cambiare il colore del testo nella barra di ricerca
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context).copyWith(
      hintColor: Colors.white,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Colors.grey[600],
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actionsIconTheme: const IconThemeData(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
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
      return const MainGradient(
        child: Center(
          child: Text('No results', style: TextStyle(color: Colors.white)),
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
                            _playOrNavigateTo(result, miniPlayerCubit, context);
                          },
                          child: ResourceTile(resource: result),
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
                      color: Colors.white,
                    ),
                    title: Text(suggestion,
                        style: const TextStyle(color: Colors.white)),
                    trailing: state.isQueryHistory
                        ? IconButton(
                            onPressed: () {
                              searchSuggestionCubit
                                  .deleteQueryFromHistory(suggestion);
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
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

  void _playOrNavigateTo(ResourceMT result, MiniPlayerCubit miniPlayerCubit,
      BuildContext context) {
    if (result.kind == 'video') {
      miniPlayerCubit.startPlaying(result.id!);
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
}

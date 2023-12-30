import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/channel/channel_view.dart';
import 'package:my_tube/ui/views/common/channel_tile.dart';
import 'package:my_tube/ui/views/common/playlist_tile.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/ui/views/playlist/playlist_view.dart';

// ignore: must_be_immutable
class SearchView extends StatelessWidget {
  SearchView({super.key});

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchBloc = context.read<SearchBloc>();
    final miniPlayerCubit = context.read<MiniPlayerCubit>();

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          StatefulBuilder(builder: (context, setState) {
            final searchSuggestionCubit = context.read<SearchSuggestionCubit>();
            final suggestions = searchSuggestionCubit.state.suggestions;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: constraints.biggest.width,
              child: Row(
                children: [
                  // Barra di ricerca

                  Flexible(
                      child: Autocomplete<String>(
                    // builder del contenuto dei suggerimenti di ricerca
                    optionsBuilder: (value) {
                      if (value.text.isEmpty) {
                        // Se il campo di ricerca è vuoto, mostro la cronologia delle ricerche
                        searchSuggestionCubit.getQueryHistory();
                        return searchSuggestionCubit.state.suggestions;
                      } else {
                        // Altrimenti mostro i suggerimenti di ricerca chiamando l'api
                        searchSuggestionCubit.getSuggestions(value.text);
                        return suggestions.where((element) => element
                            .toLowerCase()
                            .contains(value.text.toLowerCase()));
                      }
                    },

                    // Visualizzazione dei suggerimenti di ricerca
                    optionsViewBuilder: (_, onSelected, __) {
                      final suggestionsState =
                          context.watch<SearchSuggestionCubit>().state;
                      final options = suggestionsState.suggestions;
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          clipBehavior: Clip.antiAlias,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: SizedBox(
                            height: 52.0 * options.length,
                            width: constraints.biggest.width -
                                32, // -32 per compensare il margin del container
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  leading: Icon(suggestionsState.isQueryHistory
                                      ? Icons.history
                                      : Icons.search),
                                  title: Text(option),
                                  trailing: suggestionsState.isQueryHistory
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            searchSuggestionCubit
                                                .deleteQueryFromHistory(option);
                                          },
                                        )
                                      : null,
                                  onTap: () {
                                    onSelected(option);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },

                    // Builder del campo di ricerca
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                      searchController = controller;

                      // Ascolto i cambiamenti del campo di ricerca per aggiornare la UI all'Icona di clear
                      searchController.addListener(() {
                        setState(() {});
                      });

                      return TextField(
                        controller: searchController,
                        focusNode: focusNode,
                        onEditingComplete: onFieldSubmitted,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: searchController.text.isNotEmpty
                                ? () {
                                    setState(() {
                                      searchController.clear();
                                      FocusScope.of(context).unfocus();
                                    });
                                  }
                                : null,
                          ),
                          hintText: 'Search',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none),
                        ),
                        onSubmitted: (query) => context
                            .read<SearchBloc>()
                            .add(SearchContents(query: query)),
                      );
                    },
                    onSelected: (selected) {
                      _onSelected(suggestions, selected, context);
                    },
                  )),

                  // Clear button
                ],
              ),
            );
          }),

          // Risultati della ricerca
          Expanded(child: BlocBuilder<SearchBloc, SearchState>(
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
                            query: searchController.text,
                            nextPageToken: state.result!.nextPageToken!));
                      }
                    }
                    return false;
                  },
                  child: state.result!.resources.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: state.result!.resources.length,
                          itemBuilder: (context, index) {
                            final result = state.result!.resources[index];
                            return GestureDetector(
                                onTap: () {
                                  _playOrNavigateTo(
                                      result, miniPlayerCubit, context);
                                },
                                child: _setTile(result));
                          })
                      : const Center(child: Text('No results found')),
                );
              case SearchStatus.failure:
                return Center(child: Text(state.error!));

              default:
                return const Center(child: Text('Todo widget here'));
            }
          }))
        ]),
      );
    });
  }

  void _playOrNavigateTo(ResourceMT result, MiniPlayerCubit miniPlayerCubit,
      BuildContext context) {
    if (result.kind == 'video') {
      miniPlayerCubit.startPlaying(result.id!);
    }

    if (result.kind == 'channel') {
      /* context.go('${AppRoute.search.path}/${AppRoute.channel.path}',
          extra: {'channelId': result.channelId!}); */
      showBottomSheet(
          context: context,
          builder: (context) => ChannelView(channelId: result.channelId!));
    }

    if (result.kind == 'playlist') {
      /* context.go('${AppRoute.search.path}/${AppRoute.playlist.path}',
          extra: {'playlist': result.title!, 'playlistId': result.playlistId!}); */
      showBottomSheet(
          context: context,
          builder: (context) => PlaylistView(playlistId: result.playlistId!));
    }
  }

  void _onSelected(
      List<String> suggestions, String selected, BuildContext context) {
    searchController.text = selected;
    context.read<SearchBloc>().add(SearchContents(query: selected));

    FocusScope.of(context).unfocus();
  }

  Widget _setTile(ResourceMT result) {
    if (result.kind == 'video') {
      return VideoTile(video: result);
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

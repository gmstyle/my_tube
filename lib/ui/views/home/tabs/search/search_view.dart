import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/channel_grid_item.dart';
import 'package:my_tube/ui/views/common/channel_tile.dart';
import 'package:my_tube/ui/views/common/channel_playlist_menu_dialog.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/playlist_grid_item.dart';
import 'package:my_tube/ui/views/common/playlist_tile.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/ui/views/home/tabs/search/widgets/empty_search.dart';
import 'package:my_tube/utils/enums.dart';

// ignore: must_be_immutable
class SearchView extends StatelessWidget {
  SearchView({super.key});

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchBloc = context.read<SearchBloc>();

    return LayoutBuilder(builder: (context, constraints) {
      return Column(children: [
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
                      return searchSuggestionCubit.state.suggestions.reversed
                          .toList();
                    } else {
                      // Altrimenti mostro i suggerimenti di ricerca chiamando l'api
                      searchSuggestionCubit.getSuggestions(value.text);
                      return suggestions;
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
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.8),
                        clipBehavior: Clip.antiAlias,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        )),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.4,
                                minWidth: constraints.biggest.width,
                                maxWidth: constraints.biggest.width),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 5.0,
                                      children: List<Widget>.generate(
                                          options.length,
                                          (index) => InputChip(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                label: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (suggestionsState
                                                        .isQueryHistory) ...[
                                                      const Icon(Icons.history,
                                                          size: 16),
                                                      const SizedBox(width: 4)
                                                    ],
                                                    Text(options[index]),
                                                  ],
                                                ),
                                                onPressed: () =>
                                                    onSelected(options[index]),
                                                onDeleted: suggestionsState
                                                        .isQueryHistory
                                                    ? () {
                                                        searchSuggestionCubit
                                                            .deleteQueryFromHistory(
                                                                options[index]);
                                                      }
                                                    : null,
                                              )),
                                    )
                                  ],
                                ),
                              ),
                            )),
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
                      //onEditingComplete: onFieldSubmitted,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              FocusScope.of(context).unfocus();
                            });
                          },
                        ),
                        hintText: 'Search',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => context
                          .read<SearchBloc>()
                          .add(SearchContents(query: searchController.text)),
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
              return const CustomSkeletonGridList();
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
                    ? LayoutBuilder(builder: (context, constraints) {
                        final isTablet = constraints.maxWidth > 600;
                        if (isTablet) {
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemCount: state.result!.resources.length + 1,
                            itemBuilder: (context, index) {
                              if (index < state.result!.resources.length) {
                                final result = state.result!.resources[index];
                                return _setTile(context, result, isTablet);
                              } else {
                                if (state.result!.resources.length >= 20) {
                                  return ListLoader();
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }
                            },
                          );
                        } else {
                          return ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: state.result!.resources.length + 1,
                              itemBuilder: (context, index) {
                                if (index < state.result!.resources.length) {
                                  final result = state.result!.resources[index];
                                  return _setTile(context, result, isTablet);
                                } else {
                                  // Loader alla fine della lista se la lista è maggiore di 20
                                  if (state.result!.resources.length >= 20) {
                                    return ListLoader();
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }
                              });
                        }
                      })
                    : const Center(child: Text('No results found')),
              );
            case SearchStatus.failure:
              return Center(child: Text(state.error!));

            default:
              return const Center(child: EmptySearch());
          }
        }))
      ]);
    });
  }

  void _onSelected(
      List<String> suggestions, String selected, BuildContext context) {
    searchController.text = selected;
    context.read<SearchBloc>().add(SearchContents(query: selected));

    FocusScope.of(context).unfocus();
  }

  Widget _setTile(BuildContext context, ResourceMT result, bool isTablet) {
    if (result.kind == Kind.video.name) {
      return PlayPauseGestureDetector(
          resource: result,
          child: VideoMenuDialog(
              video: result,
              child: isTablet
                  ? VideoGridItem(video: result)
                  : VideoTile(video: result)));
    }

    if (result.kind == Kind.channel.name) {
      return GestureDetector(
          onTap: () {
            context.goNamed(AppRoute.channel.name,
                extra: {'channelId': result.channelId!});
          },
          child: ChannelPlaylistMenuDialog(
              resource: result,
              kind: Kind.channel,
              child: isTablet
                  ? ChannelGridItem(channel: result)
                  : ChannelTile(channel: result)));
    }

    if (result.kind == Kind.playlist.name) {
      return GestureDetector(
          onTap: () {
            context.goNamed(AppRoute.playlist.name, extra: {
              'playlist': result.title!,
              'playlistId': result.playlistId!
            });
          },
          child: ChannelPlaylistMenuDialog(
              resource: result,
              kind: Kind.playlist,
              child: isTablet
                  ? PlaylistGridItem(playlist: result)
                  : PlaylistTile(playlist: result)));
    }

    return Container();
  }
}

class ListLoader extends StatelessWidget {
  const ListLoader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
    );
  }
}

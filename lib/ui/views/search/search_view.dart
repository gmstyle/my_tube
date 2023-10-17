import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class SearchView extends StatelessWidget {
  SearchView({super.key});

  final TextEditingController searchController = TextEditingController()
    ..text = '';

  @override
  Widget build(BuildContext context) {
    final searchBloc = context.read<SearchBloc>();
    final miniPlayerCubit = context.read<MiniPlayerCubit>();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StatefulBuilder(builder: (context, setState) {
          // Ascolto searchController per aggiornare la UI quando cambia il testo
          searchController.addListener(() {
            setState(() {});
          });

          return Row(
            children: [
              // Campo di ricerca
              Flexible(
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (query) => context
                      .read<SearchBloc>()
                      .add(SearchContents(query: query)),
                ),
              ),

              // Clear button
              IconButton(
                color: searchController.text.isNotEmpty
                    ? Theme.of(context).iconTheme.color
                    : Colors.grey,
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    searchController.clear();
                    FocusScope.of(context).unfocus();
                  });
                },
              ),
            ],
          );
        }),
      ),
      Expanded(child:
          BlocBuilder<SearchBloc, SearchState>(builder: (_, SearchState state) {
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
              child: state.result!.videos.isNotEmpty
                  ? ListView.builder(
                      itemCount: state.result!.videos.length,
                      itemBuilder: (context, index) {
                        final result = state.result!.videos[index];
                        return GestureDetector(
                            onTap: () {
                              if (result.kind == 'youtube#video') {
                                miniPlayerCubit.showMiniPlayer(result);
                              }

                              if (result.kind == 'youtube#channel') {
                                context.go(
                                    '${AppRoute.search.path}/${AppRoute.channel.path}',
                                    extra: {'channelId': result.channelId!});
                              }
                            },
                            child: VideoTile(video: result));
                      })
                  : const Center(child: Text('No results found')),
            );
          case SearchStatus.failure:
            return Center(child: Text(state.error!));

          default:
            return const SizedBox.shrink();
        }
      }))
    ]);
  }
}

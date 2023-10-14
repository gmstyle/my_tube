import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

import '../../../blocs/home/mini_player_cubit/mini_player_cubit.dart';

class MTSearchDelegate extends SearchDelegate {
  MTSearchDelegate({required this.searchBloc, required this.miniPlayerCubit});

  final SearchBloc searchBloc;
  final MiniPlayerCubit miniPlayerCubit;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, query);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('No results'),
      );
    }
    searchBloc.add(SearchContents(query: query));

    return BlocBuilder(
        bloc: searchBloc,
        builder: (_, SearchState state) {
          switch (state.status) {
            case SearchStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case SearchStatus.success:
              return ListView.builder(
                  itemCount: state.result!.videos.length,
                  itemBuilder: (context, index) {
                    final result = state.result!.videos[index];
                    return GestureDetector(
                        onTap: () {
                          if (result.kind == 'youtube#video') {
                            miniPlayerCubit
                                .showMiniPlayer(result)
                                .then((value) => close(context, query));
                          }

                          if (result.kind == 'youtube#channel') {
                            ///TODO: implementare channel page
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Channel: ${result.channelId}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: VideoTile(video: result));
                  });
            case SearchStatus.failure:
              return Center(child: Text(state.error!));

            default:
              return Container();
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}

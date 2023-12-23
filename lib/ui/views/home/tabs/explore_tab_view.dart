import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/views/common/resource_tile.dart';
import 'package:my_tube/ui/views/common/single_selection_buttons.dart';

class ExploreTabView extends StatefulWidget {
  const ExploreTabView({super.key});

  @override
  State<ExploreTabView> createState() => _ExploreTabViewState();
}

class _ExploreTabViewState extends State<ExploreTabView> {
  final ScrollController _scrollController = ScrollController();
  final categories = const ['now', 'music', 'film', 'gaming'];
  final icons = const [
    Icons.whatshot,
    Icons.music_note,
    Icons.movie,
    Icons.videogame_asset
  ];
  String _selectedCategory = 'now';

  @override
  void initState() {
    super.initState();
    context
        .read<ExploreTabBloc>()
        .add(GetTrendingVideos(category: _selectedCategory));
  }

  @override
  Widget build(BuildContext context) {
    final exploreTabBloc = context.read<ExploreTabBloc>();

    return Column(
      children: [
        StatefulBuilder(builder: (context, setState) {
          return SingleSelectionButtons(
            items: categories,
            icons: icons,
            onSelected: (selectedIndex, selectedValue) {
              setState(() {
                _selectedCategory = selectedValue;
              });
              context
                  .read<ExploreTabBloc>()
                  .add(GetTrendingVideos(category: _selectedCategory));
            },
          );
        }),
        Expanded(
          child: BlocBuilder<ExploreTabBloc, ExploreTabState>(
            builder: (context, state) {
              switch (state.status) {
                case YoutubeStatus.loading:
                  return const Center(child: CircularProgressIndicator());

                case YoutubeStatus.loaded:
                  return RefreshIndicator(
                    onRefresh: () async {
                      exploreTabBloc
                          .add(GetTrendingVideos(category: _selectedCategory));
                    },
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        /* if (state.response?.nextPageToken != null) {
                          if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                            exploreTabBloc.add(GetNextPageTrendingVideos(
                                nextPageToken: state.response!.nextPageToken!));
                          }
                        } */

                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        controller: _scrollController,
                        itemCount: state.response!.resources.length,
                        itemBuilder: (context, index) {
                          final video = state.response?.resources[index];
                          return GestureDetector(
                              onTap: () async {
                                await context
                                    .read<MiniPlayerCubit>()
                                    .startPlaying(video);
                              },
                              child: ResourceTile(resource: video!));
                        },
                      ),
                    ),
                  );
                case YoutubeStatus.error:
                  return Center(
                    child: Text(state.error!),
                  );
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }
}

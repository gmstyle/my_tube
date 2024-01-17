import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/skeletons/skeleton_list.dart';
import 'package:my_tube/ui/views/common/single_selection_buttons.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class ExploreTabView extends StatelessWidget {
  ExploreTabView({super.key});

  final categories = const ['now', 'music', 'film', 'gaming'];

  final icons = const [
    Icons.whatshot,
    Icons.music_note,
    Icons.movie,
    Icons.videogame_asset
  ];

  String _selectedCategory = 'now';

  @override
  Widget build(BuildContext context) {
    final exploreTabBloc = context.read<ExploreTabBloc>()
      ..add(GetTrendingVideos(category: _selectedCategory));
    final miniplayerCubit = context.read<MiniPlayerCubit>();

    return Column(
      children: [
        StatefulBuilder(builder: (context, setState) {
          return SingleSelectionButtons(
            items: categories,
            icons: icons,
            onSelected: (selectedIndex, selectedValue) {
              if (_selectedCategory != selectedValue) {
                setState(() {
                  _selectedCategory = selectedValue;
                });
                exploreTabBloc
                    .add(GetTrendingVideos(category: _selectedCategory));
              }
            },
          );
        }),
        Expanded(
          child: BlocBuilder<ExploreTabBloc, ExploreTabState>(
            builder: (context, state) {
              switch (state.status) {
                case YoutubeStatus.loading:
                  return const SkeletonList();

                case YoutubeStatus.loaded:
                  return RefreshIndicator(
                    onRefresh: () async {
                      exploreTabBloc
                          .add(GetTrendingVideos(category: _selectedCategory));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: state.response!.resources.length,
                      itemBuilder: (context, index) {
                        final video = state.response?.resources[index];
                        return GestureDetector(
                            onTap: () {
                              if (miniplayerCubit
                                      .mtPlayerHandler.currentTrack?.id !=
                                  video.id) {
                                miniplayerCubit.startPlaying(video.id!);
                              }
                            },
                            child: VideoMenuDialog(
                                video: video!, child: VideoTile(video: video)));
                      },
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

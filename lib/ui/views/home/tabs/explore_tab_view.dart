import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/skeletons/skeleton_list.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/single_selection_buttons.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

enum CategoryEnum { now, music, film, gaming }

class ExploreTabView extends StatelessWidget {
  ExploreTabView({super.key});

  final icons = const [
    Icons.whatshot,
    Icons.music_note,
    Icons.movie,
    Icons.videogame_asset
  ];

  String _selectedCategory = CategoryEnum.now.name;

  @override
  Widget build(BuildContext context) {
    final exploreTabBloc = context.read<ExploreTabBloc>()
      ..add(GetTrendingVideos(category: _getCategory()));
    final miniplayerCubit = context.read<MiniPlayerCubit>();

    return Column(
      children: [
        StatefulBuilder(builder: (context, setState) {
          return SingleSelectionButtons(
            items: CategoryEnum.values.map((e) => e.name).toList(),
            icons: icons,
            onSelected: (selectedIndex, selectedValue) {
              if (_selectedCategory != selectedValue) {
                setState(() {
                  _selectedCategory = selectedValue;
                });
                exploreTabBloc.add(GetTrendingVideos(category: _getCategory()));
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
                          .add(GetTrendingVideos(category: _getCategory()));
                    },
                    child: ListView.builder(
                      itemCount: state.response!.resources.length,
                      itemBuilder: (context, index) {
                        final video = state.response?.resources[index];
                        return PlayPauseGestureDetector(
                          resource: video!,
                          child: VideoMenuDialog(
                              video: video, child: VideoTile(video: video)),
                        );
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

  CategoryEnum _getCategory() {
    return CategoryEnum.values
        .where((element) => element.name == _selectedCategory)
        .first;
  }
}

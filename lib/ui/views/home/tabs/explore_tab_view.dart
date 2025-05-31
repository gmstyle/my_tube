import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/ui/skeletons/skeleton_grid_list.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/single_selection_buttons.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

enum CategoryEnum { now, music, film, gaming }

class ExploreTabView extends StatefulWidget {
  const ExploreTabView({super.key});

  @override
  State<ExploreTabView> createState() => _ExploreTabViewState();
}

class _ExploreTabViewState extends State<ExploreTabView> {
  final icons = const [
    Icons.whatshot,
    Icons.music_note,
    Icons.movie,
    Icons.videogame_asset
  ];

  CategoryEnum _selectedCategory = CategoryEnum.now;

  @override
  Widget build(BuildContext context) {
    final exploreTabBloc = context.read<ExploreTabBloc>()
      ..add(GetTrendingVideos(category: _getCategory()));

    return Column(
      children: [
        SingleSelectionButtons(
          items: CategoryEnum.values,
          icons: icons,
          onSelected: (selectedIndex, selectedValue) {
            if (_selectedCategory != selectedValue) {
              setState(() {
                _selectedCategory = selectedValue;
              });
              exploreTabBloc.add(GetTrendingVideos(category: _getCategory()));
            }
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<ExploreTabBloc, ExploreTabState>(
            builder: (context, state) {
              switch (state.status) {
                case YoutubeStatus.loading:
                  return const SkeletonGridList();

                case YoutubeStatus.loaded:
                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      // Check if the device is a tablet
                      bool isTablet = constraints.maxWidth > 600;

                      if (isTablet) {
                        // Use GridView for tablets
                        return RefreshIndicator(
                          onRefresh: () async {
                            exploreTabBloc.add(
                                GetTrendingVideos(category: _getCategory()));
                          },
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemCount: state.response!.resources.length,
                            itemBuilder: (context, index) {
                              final video = state.response?.resources[index];
                              return PlayPauseGestureDetector(
                                resource: video!,
                                child: VideoMenuDialog(
                                    video: video,
                                    child: VideoGridItem(video: video)),
                              );
                            },
                          ),
                        );
                      } else {
                        // Use ListView for smartphones
                        return RefreshIndicator(
                          onRefresh: () async {
                            exploreTabBloc.add(
                                GetTrendingVideos(category: _getCategory()));
                          },
                          child: ListView.builder(
                            itemCount: state.response!.resources.length,
                            itemBuilder: (context, index) {
                              final video = state.response?.resources[index];
                              return PlayPauseGestureDetector(
                                resource: video!,
                                child: VideoMenuDialog(
                                    video: video,
                                    child: VideoTile(video: video)),
                              );
                            },
                          ),
                        );
                      }
                    },
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
        .where((element) => element == _selectedCategory)
        .first;
  }
}

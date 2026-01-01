import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

enum CategoryEnum { now, music, film, gaming }

class ExploreTabView extends StatefulWidget {
  const ExploreTabView({super.key});

  @override
  State<ExploreTabView> createState() => _ExploreTabViewState();
}

class _ExploreTabViewState extends State<ExploreTabView>
    with SingleTickerProviderStateMixin {
  final icons = const [
    Icons.whatshot,
    Icons.music_note,
    Icons.movie,
    Icons.videogame_asset
  ];

  CategoryEnum _selectedCategory = CategoryEnum.now;
  late final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    // Use a TabBar + TabBarView: each tab selects a category and requests trending videos
    final exploreTabBloc = context.read<ExploreTabBloc>();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: List.generate(CategoryEnum.values.length, (index) {
              final cat = CategoryEnum.values[index];
              return Tab(
                icon: Icon(icons[index], size: 20),
                text: _labelFor(cat),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(CategoryEnum.values.length, (index) {
              return _buildTabContent(context, exploreTabBloc);
            }),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: CategoryEnum.values.length, vsync: this);
    // initial load after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ExploreTabBloc>()
          .add(GetTrendingVideos(category: _getCategory()));
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      final newCat = CategoryEnum.values[_tabController.index];
      if (newCat != _selectedCategory) {
        setState(() {
          _selectedCategory = newCat;
        });
        context
            .read<ExploreTabBloc>()
            .add(GetTrendingVideos(category: _getCategory()));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _labelFor(CategoryEnum c) {
    switch (c) {
      case CategoryEnum.now:
        return 'Now';
      case CategoryEnum.music:
        return 'Music';
      case CategoryEnum.film:
        return 'Film';
      case CategoryEnum.gaming:
        return 'Gaming';
    }
  }

  Widget _buildTabContent(BuildContext context, ExploreTabBloc exploreTabBloc) {
    return BlocBuilder<ExploreTabBloc, ExploreTabState>(
        builder: (context, state) {
      switch (state.status) {
        case YoutubeStatus.initial:
        case YoutubeStatus.loading:
          return const CustomSkeletonGridList();
        case YoutubeStatus.loaded:
          return LayoutBuilder(builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            return RefreshIndicator(
              onRefresh: () async {
                exploreTabBloc.add(GetTrendingVideos(category: _getCategory()));
              },
              child: isTablet
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: state.videos?.length ?? 0,
                      itemBuilder: (context, index) {
                        final videos = state.videos;
                        if (videos == null || index >= videos.length) {
                          return const SizedBox.shrink();
                        }
                        final video = videos[index];
                        final quickVideo = <String, String>{
                          'id': video.id,
                          'title': video.title
                        };
                        return VideoMenuDialog(
                            quickVideo: quickVideo,
                            child: VideoGridItem(video: video));
                      },
                    )
                  : ListView.builder(
                      itemCount: state.videos?.length ?? 0,
                      itemBuilder: (context, index) {
                        final videos = state.videos;
                        if (videos == null || index >= videos.length) {
                          return const SizedBox.shrink();
                        }
                        final video = videos[index];
                        final quickVideo = <String, String>{
                          'id': video.id,
                          'title': video.title
                        };
                        return VideoMenuDialog(
                            quickVideo: quickVideo,
                            child: VideoTile(video: video));
                      },
                    ),
            );
          });
        case YoutubeStatus.error:
          return Center(child: Text(state.error ?? 'Unknown error occurred'));
      }
    });
  }

  CategoryEnum _getCategory() {
    return CategoryEnum.values
        .where((element) => element == _selectedCategory)
        .first;
  }
}

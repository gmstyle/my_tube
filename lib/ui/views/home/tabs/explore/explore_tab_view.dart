import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

class ExploreTabView extends StatefulWidget {
  const ExploreTabView({super.key});

  @override
  State<ExploreTabView> createState() => _ExploreTabViewState();
}

class _ExploreTabViewState extends State<ExploreTabView> {
  CategoryEnum _selectedCategory = CategoryEnum.now;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ExploreTabBloc>()
          .add(GetTrendingVideos(category: _selectedCategory));
      if (context.mounted) {
        context.read<PersistentUiCubit>().setNavBarVisibility(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          floating: true,
          snap: true,
          pinned: false,
          automaticallyImplyLeading: false,
          toolbarHeight: 48,
          forceElevated: innerBoxIsScrolled,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Text(
              'Explore',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < CategoryEnum.values.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(_labelFor(CategoryEnum.values[i])),
                        selected: _selectedCategory == CategoryEnum.values[i],
                        showCheckmark: false,
                        onSelected: (_) =>
                            _selectCategory(CategoryEnum.values[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      body: BlocBuilder<ExploreTabBloc, ExploreTabState>(
        builder: (context, state) {
          switch (state.status) {
            case YoutubeStatus.loading:
              return const CustomSkeletonGridList();
            case YoutubeStatus.error:
              return EnhancedErrorState(
                icon: Icons.explore_off,
                title: 'Could not load trending',
                message: state.error ?? 'Something went wrong. Try again.',
                showBackButton: false,
                onRetry: () => context
                    .read<ExploreTabBloc>()
                    .add(GetTrendingVideos(category: _selectedCategory)),
              );
            case YoutubeStatus.loaded:
              return _ExploreContent(
                state: state,
                onRefresh: () async => context
                    .read<ExploreTabBloc>()
                    .add(GetTrendingVideos(category: _selectedCategory)),
              );
          }
        },
      ),
    );
  }

  void _selectCategory(CategoryEnum cat) {
    if (cat == _selectedCategory) return;
    setState(() => _selectedCategory = cat);
    context.read<ExploreTabBloc>().add(GetTrendingVideos(category: cat));
  }

  String _labelFor(CategoryEnum c) {
    switch (c) {
      case CategoryEnum.now:
        return 'Trending';
      case CategoryEnum.music:
        return 'Music';
      case CategoryEnum.film:
        return 'Film';
      case CategoryEnum.gaming:
        return 'Gaming';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ExploreContent — body widget for the loaded state
// ─────────────────────────────────────────────────────────────────────────────

class _ExploreContent extends StatelessWidget {
  const _ExploreContent({required this.state, required this.onRefresh});

  final ExploreTabState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppBreakpoints.isTablet(context);
    final videos = state.videos ?? [];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: isTablet
          ? GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return PlayPauseGestureDetector(
                  id: video.id,
                  child: VideoMenuDialog(
                    quickVideo: {'id': video.id, 'title': video.title},
                    child: VideoGridItem(video: video),
                  ),
                );
              },
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView.separated(
                itemCount: videos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return PlayPauseGestureDetector(
                    id: video.id,
                    child: VideoMenuDialog(
                      quickVideo: {'id': video.id, 'title': video.title},
                      child: VideoTile(video: video),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

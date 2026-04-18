import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class ExploreMobileLayout extends StatelessWidget {
  const ExploreMobileLayout({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.labelFor,
  });

  final CategoryEnum selectedCategory;
  final void Function(CategoryEnum) onSelectCategory;
  final String Function(CategoryEnum) labelFor;

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
              padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
              child: _CategoryChipsRow(
                selectedCategory: selectedCategory,
                onSelectCategory: onSelectCategory,
                labelFor: labelFor,
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
                    .add(GetTrendingVideos(category: selectedCategory)),
              );
            case YoutubeStatus.loaded:
              final videos = state.videos ?? [];
              return RefreshIndicator(
                onRefresh: () async => context
                    .read<ExploreTabBloc>()
                    .add(GetTrendingVideos(category: selectedCategory)),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: videos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return PlayPauseGestureDetector(
                      id: video.id,
                      child: VideoMenuDialog(
                        quickVideo: {
                          'id': video.id,
                          'title': video.title,
                        },
                        child: VideoTile(video: video),
                      ),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared category chips row — reused across layouts
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChipsRow extends StatelessWidget {
  const _CategoryChipsRow({
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.labelFor,
  });

  final CategoryEnum selectedCategory;
  final void Function(CategoryEnum) onSelectCategory;
  final String Function(CategoryEnum) labelFor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < CategoryEnum.values.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            ChoiceChip(
              label: Text(labelFor(CategoryEnum.values[i])),
              selected: selectedCategory == CategoryEnum.values[i],
              showCheckmark: false,
              onSelected: (_) => onSelectCategory(CategoryEnum.values[i]),
            ),
          ],
        ],
      ),
    );
  }
}

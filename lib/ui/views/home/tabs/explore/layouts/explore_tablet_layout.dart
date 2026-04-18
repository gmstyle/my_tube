import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/services/player/mt_player_service.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/ui/views/common/material_interactive_components.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/spectrum_playing_icon.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/utils/utils.dart';

class ExploreTabletLayout extends StatelessWidget {
  const ExploreTabletLayout({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.labelFor,
  });

  final CategoryEnum selectedCategory;
  final void Function(CategoryEnum) onSelectCategory;
  final String Function(CategoryEnum) labelFor;

  static const double _sidebarWidth = 220.0;
  static const double _contentMaxWidth = 1200.0;
  static const int _crossAxisCount = 4;
  static const double _gridSpacing = 12.0;
  static const double _gridPadding = 16.0;
  static const double _childAspectRatio = 16 / 10;

  IconData _iconFor(CategoryEnum c) {
    switch (c) {
      case CategoryEnum.now:
        return Icons.whatshot;
      case CategoryEnum.music:
        return Icons.music_note;
      case CategoryEnum.film:
        return Icons.movie;
      case CategoryEnum.gaming:
        return Icons.sports_esports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        // ── Top AppBar ────────────────────────────────────────────────
        Material(
          color: cs.surface,
          elevation: 0,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Explore',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        // ── Body ──────────────────────────────────────────────────────
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Row(
                children: [
                  // ── Sidebar ────────────────────────────────────────
                  SizedBox(
                    width: _sidebarWidth,
                    child: Material(
                      color: cs.surfaceContainerLow,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        children: [
                          for (final cat in CategoryEnum.values)
                            _SidebarItem(
                              icon: _iconFor(cat),
                              label: labelFor(cat),
                              selected: selectedCategory == cat,
                              onTap: () => onSelectCategory(cat),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  // ── Content ────────────────────────────────────────
                  Expanded(
                    child: BlocBuilder<ExploreTabBloc, ExploreTabState>(
                      builder: (context, state) {
                        switch (state.status) {
                          case YoutubeStatus.loading:
                            return const CustomSkeletonExploreTablet();
                          case YoutubeStatus.error:
                            return EnhancedErrorState(
                              icon: Icons.explore_off,
                              title: 'Could not load trending',
                              message: state.error ??
                                  'Something went wrong. Try again.',
                              showBackButton: false,
                              onRetry: () => context.read<ExploreTabBloc>().add(
                                  GetTrendingVideos(
                                      category: selectedCategory)),
                            );
                          case YoutubeStatus.loaded:
                            final videos = state.videos ?? [];
                            if (videos.isEmpty) return const SizedBox.shrink();
                            final hero = videos.first;
                            final rest = videos.skip(1).toList();
                            return RefreshIndicator(
                              onRefresh: () async => context
                                  .read<ExploreTabBloc>()
                                  .add(GetTrendingVideos(
                                      category: selectedCategory)),
                              child: CustomScrollView(
                                slivers: [
                                  // ── Hero card ──────────────────────
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          _gridPadding,
                                          _gridPadding,
                                          _gridPadding,
                                          8),
                                      child: _ExploreHeroCard(video: hero),
                                    ),
                                  ),
                                  // ── 4-column grid ──────────────────
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                        _gridPadding,
                                        8,
                                        _gridPadding,
                                        _gridPadding),
                                    sliver: SliverGrid(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: _crossAxisCount,
                                        mainAxisSpacing: _gridSpacing,
                                        crossAxisSpacing: _gridSpacing,
                                        childAspectRatio: _childAspectRatio,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final video = rest[index];
                                          return PlayPauseGestureDetector(
                                            id: video.id,
                                            child: VideoMenuDialog(
                                              quickVideo: {
                                                'id': video.id,
                                                'title': video.title,
                                              },
                                              child:
                                                  VideoGridItem(video: video),
                                            ),
                                          );
                                        },
                                        childCount: rest.length,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero card — full-width, 16:9, first trending video
// ─────────────────────────────────────────────────────────────────────────────

class _ExploreHeroCard extends StatelessWidget {
  const _ExploreHeroCard({required this.video});

  final VideoTile video;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mtPlayerService = context.watch<MtPlayerService>();
    final playerCubit = context.read<PlayerCubit>();

    return VideoMenuDialog(
      quickVideo: {'id': video.id, 'title': video.title},
      child: MaterialHoverContainer(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (mtPlayerService.currentTrack?.id != video.id) {
            playerCubit.startPlaying(video.id);
          } else {
            if (mtPlayerService.playbackState.value.playing) {
              mtPlayerService.pause();
            } else {
              mtPlayerService.play();
            }
          }
        },
        child: SizedBox(
          height: 260,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail
                Utils.buildImageWithFallback(
                  thumbnailUrl: video.thumbnailUrl,
                  context: context,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.play_arrow_rounded,
                        size: 64, color: theme.colorScheme.primary),
                  ),
                ),

                // Gradient overlay
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Color(0x55000000),
                        Color(0xCC000000),
                      ],
                      stops: [0.0, 0.45, 0.7, 1.0],
                    ),
                  ),
                ),

                // Active playing border
                StreamBuilder(
                  stream: mtPlayerService.mediaItem,
                  builder: (context, snapshot) {
                    if (snapshot.data?.id == video.id) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 3,
                          ),
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Text info bottom-left
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "Trending #1" badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#1 Trending',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          shadows: const [
                            Shadow(blurRadius: 4, color: Colors.black54),
                          ],
                        ),
                      ),
                      if (video.artist != null && video.artist!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          video.artist!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Spectrum icon top-right
                Positioned(
                  top: 12,
                  right: 12,
                  child: SpectrumPlayingIcon(
                    videoId: video.id,
                    barColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar navigation item
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? cs.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color:
                      selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: tt.bodyMedium?.copyWith(
                    color: selected
                        ? cs.onSecondaryContainer
                        : cs.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

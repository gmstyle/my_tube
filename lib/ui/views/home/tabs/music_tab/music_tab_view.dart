import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/music_tab/music_tab_bloc.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MusicTabView
// ─────────────────────────────────────────────────────────────────────────────

class MusicTabView extends StatefulWidget {
  const MusicTabView({super.key});

  @override
  State<MusicTabView> createState() => _MusicTabViewState();
}

class _MusicTabViewState extends State<MusicTabView> {
  // NOTE: dispatch is already sent by MusicTabPage; initState is intentionally
  // left without an additional add() to avoid a double fetch.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<MusicTabBloc, MusicTabState>(
        builder: (context, state) {
          // ── Loading ──────────────────────────────────────────────────────
          if (state.status == MusicTabStatus.loading) {
            return const CustomSkeletonMusicHome();
          }

          // ── Error ────────────────────────────────────────────────────────
          if (state.status == MusicTabStatus.error) {
            return EnhancedErrorState(
              icon: Icons.music_off_outlined,
              title: 'Could not load music',
              message: state.error ?? 'Something went wrong. Try again.',
              showBackButton: false,
              onRetry: () =>
                  context.read<MusicTabBloc>().add(const GetMusicTabContent()),
            );
          }

          // ── Success ──────────────────────────────────────────────────────
          if (state.status == MusicTabStatus.success) {
            final isEmpty = state.newReleases.isEmpty &&
                state.discoverRelated.isEmpty &&
                state.trending.isEmpty;

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
                      'Music',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                ),
              ],
              body: isEmpty
                  ? const _MusicEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async => context
                          .read<MusicTabBloc>()
                          .add(const GetMusicTabContent()),
                      child: CustomScrollView(
                        slivers: [
                          // ── 1. New Releases ────────────────────────────
                          if (state.newReleases.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'New Releases',
                              onSeeAll: state.newReleases.length > 5
                                  ? () => _showSeeAllSheet(
                                        context,
                                        title: 'New Releases',
                                        videos: state.newReleases,
                                      )
                                  : null,
                            ),
                            _HorizontalVideoList(videos: state.newReleases),
                          ],

                          // ── 2. Discover ────────────────────────────────
                          if (state.discoverVideo != null &&
                              state.discoverRelated.isNotEmpty) ...[
                            _SectionHeader(
                              title:
                                  'Because you liked "${state.discoverVideo!.title}"',
                              onSeeAll: state.discoverRelated.length > 5
                                  ? () => _showSeeAllSheet(
                                        context,
                                        title:
                                            'Because you liked "${state.discoverVideo!.title}"',
                                        videos: state.discoverRelated,
                                      )
                                  : null,
                            ),
                            _HorizontalVideoList(videos: state.discoverRelated),
                          ],

                          // ── 3. Trending ────────────────────────────────
                          if (state.trending.isNotEmpty) ...[
                            _SectionHeader(
                              title: state.isInternationalTrending
                                  ? 'International Top Hits'
                                  : 'Trending Music',
                              onSeeAll: state.trending.length > 5
                                  ? () => _showSeeAllSheet(
                                        context,
                                        title: state.isInternationalTrending
                                            ? 'International Top Hits'
                                            : 'Trending Music',
                                        videos: state.trending,
                                        ranked: true,
                                      )
                                  : null,
                            ),
                            // Hero card for rank #1
                            SliverToBoxAdapter(
                              child: _TrendingHeroCard(
                                  video: state.trending.first),
                            ),
                            // Ranked list for #2–#5 (inline preview, max 4)
                            if (state.trending.length > 1)
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final video = state.trending[index + 1];
                                    return _RankedTile(
                                        rank: index + 2, video: video);
                                  },
                                  childCount:
                                      (state.trending.length - 1).clamp(0, 4),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionHeader — accent bar + title + optional "See all"
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 8, 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Accent vertical bar
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  foregroundColor: cs.primary,
                  textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                child: const Text('See all'),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HorizontalVideoList — responsive horizontal scroll row
// ─────────────────────────────────────────────────────────────────────────────

class _HorizontalVideoList extends StatelessWidget {
  const _HorizontalVideoList({required this.videos});

  final List<models.VideoTile> videos;

  @override
  Widget build(BuildContext context) {
    final cardHeight = context.isTablet ? 210.0 : 175.0;
    final cardWidth = context.isTablet ? 290.0 : 240.0;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: cardHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: videos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final video = videos[index];
            return SizedBox(
              width: cardWidth,
              child: PlayPauseGestureDetector(
                id: video.id,
                child: VideoMenuDialog(
                  quickVideo: {'id': video.id, 'title': video.title},
                  child: VideoGridItem(video: video),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TrendingHeroCard — rank #1, thumbnail espansa
// ─────────────────────────────────────────────────────────────────────────────

class _TrendingHeroCard extends StatelessWidget {
  const _TrendingHeroCard({required this.video});

  final models.VideoTile video;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: PlayPauseGestureDetector(
        id: video.id,
        child: VideoMenuDialog(
          quickVideo: {'id': video.id, 'title': video.title},
          child: Card(
            elevation: theme.enhancedCardTheme.elevation,
            shape: theme.enhancedCardTheme.shape,
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail (16:9)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: cs.surfaceContainerHighest,
                      child: Icon(Icons.music_note,
                          size: 48, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
                // Info row
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rank badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#1',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (video.artist != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                video.artist!,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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
// _RankedTile — numerazione #2, #3... per la lista trending
// ─────────────────────────────────────────────────────────────────────────────

class _RankedTile extends StatelessWidget {
  const _RankedTile({required this.rank, required this.video});

  final int rank;
  final models.VideoTile video;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: PlayPauseGestureDetector(
              id: video.id,
              child: VideoMenuDialog(
                quickVideo: {'id': video.id, 'title': video.title},
                child: VideoTile(video: video),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MusicEmptyState — nessun contenuto personalizzato
// ─────────────────────────────────────────────────────────────────────────────

class _MusicEmptyState extends StatelessWidget {
  const _MusicEmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_outlined,
                size: 72, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 20),
            Text(
              'Your music, your way',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Save some favorites to get personalized picks',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _showSeeAllSheet — apre il bottom sheet con la lista completa
// ─────────────────────────────────────────────────────────────────────────────

void _showSeeAllSheet(
  BuildContext context, {
  required String title,
  required List<models.VideoTile> videos,
  bool ranked = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _SeeAllSheet(title: title, videos: videos, ranked: ranked),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SeeAllSheet — DraggableScrollableSheet con lista verticale
// ─────────────────────────────────────────────────────────────────────────────

class _SeeAllSheet extends StatelessWidget {
  const _SeeAllSheet(
      {required this.title, required this.videos, this.ranked = false});

  final String title;
  final List<models.VideoTile> videos;
  final bool ranked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Scaffold(
            backgroundColor: cs.surface,
            body: Column(
              children: [
                // ── Drag handle ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outline.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // ── Header ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${videos.length} tracks',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          foregroundColor: cs.onSurfaceVariant,
                          minimumSize: const Size(36, 36),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: cs.outline.withValues(alpha: 0.15),
                ),
                // ── Video list ────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        if (ranked) {
                          return _RankedTile(rank: index + 1, video: video);
                        }
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
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

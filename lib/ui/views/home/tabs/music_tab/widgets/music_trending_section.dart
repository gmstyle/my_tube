import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';
import 'package:my_tube/utils/constants.dart';

/// Large hero card for the #1 trending track (16:9 thumbnail + info row).
class MusicTrendingHeroCard extends StatelessWidget {
  const MusicTrendingHeroCard({super.key, required this.video});

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

/// Ranked list tile for trending positions #2 and beyond.
class MusicRankedTile extends StatelessWidget {
  const MusicRankedTile({super.key, required this.rank, required this.video});

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
// Tablet trending: hero card (left) + ranked list (right), side by side
// ─────────────────────────────────────────────────────────────────────────────

/// Tablet-only trending section: #1 hero with full-bleed cover on the left,
/// ranked tracks #2–#5 on the right.
class MusicTrendingTabletSection extends StatelessWidget {
  const MusicTrendingTabletSection({
    super.key,
    required this.trending,
    this.onSeeAll,
  });

  final List<models.VideoTile> trending;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final hero = trending.first;
    final rest = trending.skip(1).take(4).toList();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: SizedBox(
          height: 320,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero card ──────────────────────────────────────────
              Expanded(
                child: PlayPauseGestureDetector(
                  id: hero.id,
                  child: VideoMenuDialog(
                    quickVideo: {'id': hero.id, 'title': hero.title},
                    child: Card(
                      elevation: theme.enhancedCardTheme.elevation,
                      shape: theme.enhancedCardTheme.shape,
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.zero,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Full-bleed thumbnail
                          Positioned.fill(
                            child: Image.network(
                              hero.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: cs.surfaceContainerHighest,
                                child: Icon(
                                  Icons.music_note,
                                  size: 48,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          // Bottom gradient + info overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.85),
                                  ],
                                ),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(12, 32, 12, 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: cs.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '#1',
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: cs.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          hero.title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (hero.artist != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            hero.artist!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Colors.white70,
                                            ),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // ── Ranked list ────────────────────────────────────────
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: rest.length,
                        itemBuilder: (_, i) =>
                            _RankedItem(rank: i + 2, video: rest[i]),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                      ),
                    ),
                    if (onSeeAll != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onSeeAll,
                          style: TextButton.styleFrom(
                            foregroundColor: cs.primary,
                            textStyle: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text(sectionSeeAllLabel),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact ranked row used inside [MusicTrendingTabletSection].
class _RankedItem extends StatelessWidget {
  const _RankedItem({required this.rank, required this.video});

  final int rank;
  final models.VideoTile video;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
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
    );
  }
}

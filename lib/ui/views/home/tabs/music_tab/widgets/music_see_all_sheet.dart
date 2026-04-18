import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_trending_section.dart';

/// Opens a bottom sheet with the full list of [videos] for a given section.
/// Pass [ranked] to render each item as a [MusicRankedTile].
void showMusicSeeAllSheet(
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
    builder: (_) =>
        _MusicSeeAllSheet(title: title, videos: videos, ranked: ranked),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _MusicSeeAllSheet — DraggableScrollableSheet with a vertical video list
// ─────────────────────────────────────────────────────────────────────────────

class _MusicSeeAllSheet extends StatelessWidget {
  const _MusicSeeAllSheet(
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
                          return MusicRankedTile(rank: index + 1, video: video);
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
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
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

// ─────────────────────────────────────────────────────────────────────────────
// Tablet: side sheet sliding in from the right edge (M3 pattern)
// ─────────────────────────────────────────────────────────────────────────────

/// Opens a side sheet from the right edge — the tablet alternative to
/// [showMusicSeeAllSheet].
void showMusicSeeAllSideSheet(
  BuildContext context, {
  required String title,
  required List<models.VideoTile> videos,
  bool ranked = false,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, _, __) => SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: _MusicSeeAllSideSheet(
          title: title,
          videos: videos,
          ranked: ranked,
        ),
      ),
    ),
    transitionBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      );
    },
  );
}

class _MusicSeeAllSideSheet extends StatelessWidget {
  const _MusicSeeAllSideSheet({
    required this.title,
    required this.videos,
    this.ranked = false,
  });

  final String title;
  final List<models.VideoTile> videos;
  final bool ranked;

  static const double _sheetWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surface,
      elevation: 8,
      surfaceTintColor: cs.surfaceTint,
      child: SizedBox(
        width: _sheetWidth,
        height: double.infinity,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
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
            Divider(height: 1, color: cs.outline.withValues(alpha: 0.15)),
            // ── Video list ────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.separated(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    if (ranked) {
                      return MusicRankedTile(rank: index + 1, video: video);
                    }
                    return PlayPauseGestureDetector(
                      id: video.id,
                      child: VideoMenuDialog(
                        quickVideo: {'id': video.id, 'title': video.title},
                        child: VideoTile(video: video),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

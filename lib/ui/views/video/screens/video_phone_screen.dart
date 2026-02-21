import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/services/player/mt_player_service.dart';
import 'package:my_tube/ui/views/common/expandable_text.dart';
import 'package:my_tube/ui/views/common/horizontal_swipe_to_skip.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';
import 'package:my_tube/ui/views/video/widget/controls.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/queue_draggable_sheet.dart';
import 'package:my_tube/ui/views/video/widget/video_action_row.dart';

class VideoPhoneScreen extends StatelessWidget {
  const VideoPhoneScreen({
    super.key,
    required this.mtPlayerService,
    this.mediaItem,
    required this.aspectRatio,
  });

  final MtPlayerService mtPlayerService;
  final MediaItem? mediaItem;
  final double aspectRatio;

  // How many pixels the info card overlaps the bottom of the video
  static const double _cardOverlap = 24.0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final videoHeight = MediaQuery.of(context).size.height * 0.37;

    return Stack(
      children: [
        // ── Video pinned at top, full width ───────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: videoHeight,
            child: HorizontalSwipeToSkip(
              child: Hero(
                tag: 'video_image_or_player',
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Chewie(controller: mtPlayerService.chewieController!),
                ),
              ),
            ),
          ),
        ),

        // ── Info card overlapping the video bottom edge ───────────────
        Positioned(
          top: videoHeight - _cardOverlap,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // drag handle pill
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // title
                  Text(
                    mediaItem?.title ?? '',
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),

                  // channel / album
                  Text(
                    mediaItem?.album ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // seek bar
                  const SeekBar(darkBackground: false, showTimings: true),

                  // playback controls
                  const Controls(),
                  const SizedBox(height: 8),

                  // download + favorite
                  VideoActionRow(mediaItem: mediaItem),

                  // description (expandable)
                  if (mediaItem?.extras?['description'] != null &&
                      mediaItem!.extras!['description'] != '')
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ExpandableText(
                        title: 'Description',
                        text: mediaItem?.extras!['description'] ?? '',
                      ),
                    ),

                  // bottom padding so content clears the queue sheet handle
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),

        // ── Semi-transparent back button overlay on the video ─────────
        if (context.canPop())
          Positioned(
            top: topPadding + 8,
            left: 8,
            child: _OverlayIconButton(
              icon: Icons.keyboard_arrow_down,
              onTap: () => context.pop(),
            ),
          ),

        // ── Queue draggable sheet ─────────────────────────────────────
        const QueueDraggableSheet(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Semi-transparent circular icon button for overlaying on the video
// ─────────────────────────────────────────────────────────────────────────────

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/services/player/mt_player_service.dart';
import 'package:my_tube/ui/views/common/expandable_text.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';
import 'package:my_tube/ui/views/video/widget/controls.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/clear_queue_button.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/media_item_list.dart';
import 'package:my_tube/ui/views/video/widget/video_action_row.dart';

/// Desktop layout for video view (>= 840dp)
/// Shows video on the left with details below it,
/// and the queue on the right side.
class VideoDesktopLayout extends StatelessWidget {
  const VideoDesktopLayout({
    super.key,
    required this.mtPlayerService,
    this.mediaItem,
    required this.aspectRatio,
  });

  final MtPlayerService mtPlayerService;
  final MediaItem? mediaItem;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1400),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left: Video + Info ─────────────────────────────────
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video player
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 540),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: aspectRatio,
                            child: Hero(
                              tag: 'video_image_or_player',
                              child: Chewie(
                                controller: mtPlayerService.chewieController!,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        mediaItem?.title ?? '',
                        maxLines: 2,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),

                      // Channel / Album
                      Text(
                        mediaItem?.album ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Seek bar + playback controls
                      const SeekBar(showTimings: true),
                      const Controls(),
                      const SizedBox(height: 8),

                      // Action row: download + favorite
                      VideoActionRow(mediaItem: mediaItem),
                      const SizedBox(height: 16),

                      // Description
                      if (mediaItem?.extras?['description'] != null &&
                          mediaItem!.extras!['description'] != '')
                        ExpandableText(
                          title: 'Description',
                          text: mediaItem?.extras!['description'] ?? '',
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // ── Right: Queue ───────────────────────────────────────
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Queue header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.queue_music,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Queue',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const Spacer(),
                        const ClearQueueButton(),
                        // Repeat mode
                        StreamBuilder(
                          stream: mtPlayerService.playbackState
                              .map((state) => state.repeatMode)
                              .distinct(),
                          builder: (context, snapshot) {
                            final repeatMode =
                                snapshot.data ?? AudioServiceRepeatMode.none;
                            final icons = [
                              Icon(Icons.repeat,
                                  color: Theme.of(context).colorScheme.primary),
                              Icon(Icons.repeat_one,
                                  color: Theme.of(context).colorScheme.primary),
                              Icon(Icons.repeat,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5)),
                            ];
                            const cycleModes = [
                              AudioServiceRepeatMode.all,
                              AudioServiceRepeatMode.one,
                              AudioServiceRepeatMode.none,
                            ];
                            final index = cycleModes.indexOf(repeatMode);
                            return IconButton(
                              icon: icons[index],
                              onPressed: () {
                                final cycleMode =
                                    cycleModes[(index + 1) % cycleModes.length];
                                mtPlayerService.setRepeatMode(cycleMode);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Expanded(child: MediaItemList()),
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

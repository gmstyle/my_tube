import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

/// Sliver with a horizontal scrolling row of video cards.
class MusicHorizontalVideoList extends StatelessWidget {
  const MusicHorizontalVideoList({super.key, required this.videos});

  final List<models.VideoTile> videos;

  @override
  Widget build(BuildContext context) {
    final isExpanded =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.medium;
    final cardHeight = isExpanded ? 210.0 : 175.0;
    final cardWidth = isExpanded ? 290.0 : 240.0;

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

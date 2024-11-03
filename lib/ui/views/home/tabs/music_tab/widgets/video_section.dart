import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class VideoSection extends StatelessWidget {
  const VideoSection(
      {super.key, required this.videos, this.crossAxisCount = 1});
  final List<ResourceMT> videos;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final double size = isLandscape ? screenHeight * 0.4 : screenHeight * 0.2;
    final double minSize = 100.0; // Dimensione minima per smartphone
    final double maxSize = 150.0; // Dimensione massima per tablet

    final double gridHeight = size.clamp(minSize, maxSize);
    final mainAxisExtent = isLandscape ? screenHeight - 64 : screenWidth - 64;

    return SizedBox(
      height: gridHeight,
      child: GridView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          itemCount: videos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8,
              mainAxisExtent: mainAxisExtent),
          itemBuilder: (context, index) {
            final video = videos[index];
            return PlayPauseGestureDetector(
              resource: video,
              child: crossAxisCount > 1
                  ? VideoMenuDialog(
                      video: video, child: VideoTile(video: video))
                  : VideoMenuDialog(
                      video: video, child: VideoGridItem(video: video)),
            );
          }),
    );
  }
}

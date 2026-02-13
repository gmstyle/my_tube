import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/shared_content_tile.dart';
import 'package:my_tube/models/tiles.dart' as models;

class VideoTile extends StatefulWidget {
  const VideoTile({
    super.key,
    required this.video,
    this.index = 0,
    this.enableScrollAnimation = false,
    this.onTap,
  });

  final models.VideoTile video;
  final int index;
  final bool enableScrollAnimation;
  final VoidCallback? onTap;

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  @override
  Widget build(BuildContext context) {
    final data = TileData.fromVideo(widget.video);
    final child = SharedContentTile(
      data: data,
      showActions: true,
      enableScrollAnimation: widget.enableScrollAnimation,
      index: widget.index,
    );

    return PlayPauseGestureDetector(
        id: widget.video.id, onTap: widget.onTap, child: child);
  }
}

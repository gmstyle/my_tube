import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/video_mt.dart';

class VideoTile extends StatelessWidget {
  const VideoTile({super.key, required this.video});

  final VideoMT video;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(video.thumbnailUrl),
      title: Text(
        video.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(video.channelTitle!),
    );
  }
}

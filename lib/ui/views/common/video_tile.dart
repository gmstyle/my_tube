import 'package:flutter/material.dart';
import 'package:my_tube/models/video_mt.dart';

class VideoTile extends StatelessWidget {
  const VideoTile({super.key, required this.video});

  final VideoMT video;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: video.thumbnailUrl != null
          ? Image.network(
              video.thumbnailUrl!,
            )
          : const SizedBox(
              child: Icon(Icons.video_collection),
            ),
      title: Text(
        video.title ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(video.channelTitle ?? ''),
    );
  }
}

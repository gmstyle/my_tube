import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';

class VideoTile extends StatelessWidget {
  const VideoTile({super.key, required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(video.snippet!.thumbnails!.medium!.url!),
      title: Text(
        video.snippet!.title!,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(video.snippet!.channelTitle!),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';

class VideoPlayerView extends StatelessWidget {
  const VideoPlayerView({super.key, required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(video.snippet!.title!),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(video.snippet!.thumbnails!.high!.url!),
              Text(video.snippet!.description!),
            ],
          ),
        ));
  }
}

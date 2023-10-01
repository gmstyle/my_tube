import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';

class VideoPlayerView extends StatelessWidget {
  const VideoPlayerView(
      {super.key,
      required this.video,
      required this.streamUrl,
      required this.chewieController});

  final Video video;
  final String streamUrl;
  final ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          video.snippet!.title!,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio:
                chewieController.videoPlayerController.value.aspectRatio,
            child: Chewie(
              controller: chewieController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  video.snippet!.title!,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  video.snippet!.description!,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

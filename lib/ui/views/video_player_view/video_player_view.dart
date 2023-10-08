import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/video_mt.dart';

class VideoPlayerView extends StatelessWidget {
  const VideoPlayerView(
      {super.key,
      required this.video,
      required this.searchResult,
      required this.streamUrl,
      required this.chewieController});

  final VideoMT? video;
  final SearchResult? searchResult;
  final String streamUrl;
  final ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(
              video != null ? video!.title : searchResult!.snippet!.title!),
          pinned: true,
          expandedHeight: MediaQuery.of(context).size.height * 0.4,
          flexibleSpace: FlexibleSpaceBar(
            background: AspectRatio(
              aspectRatio:
                  chewieController.videoPlayerController.value.aspectRatio,
              child: Chewie(
                controller: chewieController,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  /* Text(
                    video.snippet!.title!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    video.snippet!.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ), */
                ],
              ),
            ),
          ]),
        ),
      ],
    ));
  }
}

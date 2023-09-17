import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key, required this.video});

  final Video video;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late YoutubePlayerController youtubePlayerController;

  @override
  void initState() {
    super.initState();

    youtubePlayerController = YoutubePlayerController.fromVideoId(
      videoId: widget.video.id!,
      autoPlay: true,
      params: const YoutubePlayerParams(
          showControls: true, showFullscreenButton: true, loop: false),
    );

    youtubePlayerController.setFullScreenListener((isFullScreen) {
      log('isFullScreen $isFullScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
        builder: (context, player) {
          return Scaffold(
              body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(widget.video.snippet!.title!),
                expandedHeight: 250,
                flexibleSpace: FlexibleSpaceBar(
                  background: player,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: const Text('Description'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(widget.video.snippet!.description!),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          title: const Text('Statistics'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text('View Count: '),
                                      Text(widget.video.statistics!.viewCount!),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Like Count: '),
                                      Text(widget.video.statistics!.likeCount!),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Comments: '),
                                      Text(widget
                                          .video.statistics!.commentCount!),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
        },
        controller: youtubePlayerController);
  }
}

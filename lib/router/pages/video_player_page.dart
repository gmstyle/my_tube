import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/ui/views/video_player_view/video_player_view.dart';

class VideoPlayerPage extends Page {
  const VideoPlayerPage(
      {Key? key,
      required this.video,
      required this.result,
      required this.streamUrl,
      required this.chewieController});

  final VideoMT? video;
  final SearchResult? result;
  final String streamUrl;
  final ChewieController chewieController;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return VideoPlayerView(
          video: video,
          searchResult: result,
          streamUrl: streamUrl,
          chewieController: chewieController,
        );
      },
    );
  }
}

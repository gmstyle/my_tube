import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/ui/views/video_player_view/video_player_view.dart';

class VideoPlayerPage extends Page {
  const VideoPlayerPage(
      {Key? key,
      required this.video,
      required this.streamUrl,
      required this.vlcPlayerController});

  final Video video;
  final String streamUrl;
  final VlcPlayerController vlcPlayerController;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return VideoPlayerView(
          video: video,
          streamUrl: streamUrl,
          vlcPlayerController: vlcPlayerController,
        );
      },
    );
  }
}

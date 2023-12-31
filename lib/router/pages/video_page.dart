import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/video_view/video_view.dart';

class VideoPage extends Page {
  const VideoPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => const VideoView(),
    );
  }
}

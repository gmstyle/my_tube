import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/song_view/song_view.dart';

class SongPage extends Page {
  const SongPage({Key? key, required this.video});

  final ResourceMT? video;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return SongView(video: video);
        });
  }
}

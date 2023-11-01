import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/song_view/song_view.dart';

class SongPage extends Page {
  const SongPage({
    Key? key,
  });

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return SongView();
        });
  }
}

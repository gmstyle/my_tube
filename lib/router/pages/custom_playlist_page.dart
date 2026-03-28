import 'package:flutter/material.dart';
import 'package:my_tube/models/custom_playlist.dart';
import 'package:my_tube/ui/views/playlist/custom_playlist_view.dart';

class CustomPlaylistPage extends Page {
  const CustomPlaylistPage({super.key, required this.playlist});

  final CustomPlaylist playlist;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return CustomPlaylistView(initialPlaylist: playlist);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/ui/views/playlist/playlist_view.dart';

class PlaylistPage extends Page {
  const PlaylistPage({super.key, required this.playlistId});

  final String playlistId;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return MultiBlocProvider(providers: [
            BlocProvider<PlaylistBloc>(
                create: (context) =>
                    PlaylistBloc(innertubeRepository: context.read())
                      ..add(GetPlaylist(playlistId: playlistId))),
          ], child: PlaylistView(playlistId: playlistId));
        });
  }
}

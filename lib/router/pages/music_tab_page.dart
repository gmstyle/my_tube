import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/music_tab/music_tab_bloc.dart';
import 'package:my_tube/respositories/favorite_repository.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/music_tab_view.dart';

class MusicTabPage extends Page {
  const MusicTabPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return MultiBlocProvider(providers: [
            BlocProvider<MusicTabBloc>(
                create: (_) => MusicTabBloc(
                    youtubeExplodeRepository:
                        context.read<YoutubeExplodeRepository>(),
                    favoriteRepository: context.read<FavoriteRepository>())
                  ..add(const GetMusicTabContent())),
          ], child: const MusicTabView());
        });
  }
}

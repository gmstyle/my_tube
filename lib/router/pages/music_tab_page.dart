import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/music_tab/music_tab_bloc.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/music_tab_view.dart';

class MusicTabPAge extends Page {
  const MusicTabPAge({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return MultiBlocProvider(providers: [
            BlocProvider<MusicTabBloc>(
                create: (_) => MusicTabBloc(
                    innertubeRepository: context.read<InnertubeRepository>())
                  ..add(const GetMusicHome())),
          ], child: const MusicTabView());
        });
  }
}

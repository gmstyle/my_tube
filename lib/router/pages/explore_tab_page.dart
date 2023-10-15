import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/ui/views/home/tabs/explore_tab_view.dart';

class ExploreTabPage extends Page {
  const ExploreTabPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          final youtubeRepository = context.read<YoutubeRepository>();

          return MultiBlocProvider(providers: [
            BlocProvider<ExploreTabBloc>(
                create: (_) =>
                    ExploreTabBloc(youtubeRepository: youtubeRepository)
                      ..add(const GetTrendingVideos())),
          ], child: ExploreTabView());
        });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/ui/views/home/tabs/explore_tab_view.dart';

class ExploreTabPage extends Page {
  const ExploreTabPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          final youtubeExplodeRepository =
              context.read<YoutubeExplodeRepository>();

          return MultiBlocProvider(providers: [
            BlocProvider<ExploreTabBloc>(
                create: (_) => ExploreTabBloc(
                    youtubeExplodeRepository: youtubeExplodeRepository)),
          ], child: ExploreTabView());
        });
  }
}

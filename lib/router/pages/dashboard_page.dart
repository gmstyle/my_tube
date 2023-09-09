import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/home_bloc.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/ui/views/dashboard/dashboard_view.dart';

class DashboardPage extends Page {
  const DashboardPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return MultiBlocProvider(providers: [
            BlocProvider<HomeBloc>(
                create: (context) => HomeBloc(
                    youtubeRepository: context.read<YoutubeRepository>())
                  ..add(const GetVideos())),
          ], child: const DashboardView());
        });
  }
}

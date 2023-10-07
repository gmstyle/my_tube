import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/auth/auth_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/respositories/auth_repository.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/ui/views/dashboard/dashboard_view.dart';

class DashboardPage extends Page {
  const DashboardPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          final youtubeRepository = context.read<YoutubeRepository>();

          return MultiBlocProvider(providers: [
            BlocProvider<AuthBloc>(
                create: (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(const CheckIfIsLoggedIn())),
            BlocProvider<ExploreTabBloc>(
                create: (_) =>
                    ExploreTabBloc(youtubeRepository: youtubeRepository)
                      ..add(const GetVideos())),
            BlocProvider<MiniPlayerCubit>(
                create: (_) =>
                    MiniPlayerCubit(youtubeRepository: youtubeRepository)),
            BlocProvider<SearchBloc>(
                create: (_) => SearchBloc(youtubeRepository: youtubeRepository))
          ], child: const DashboardView());
        });
  }
}

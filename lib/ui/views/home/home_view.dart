import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/home_bloc.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../respositories/youtube_repository.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>(
              create: (_) =>
                  HomeBloc(youtubeRepository: context.read<YoutubeRepository>())
                    ..add(const GetVideos()))
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Tube'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(const SignOut());
                },
              )
            ],
          ),
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return const Center(
                child: Text('HomeView is working'),
              );
            },
          ),
        ));
  }
}

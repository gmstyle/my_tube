import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_tab_bloc.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab_view.dart';

class FavoritesTabPAge extends Page {
  const FavoritesTabPAge({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return MultiBlocProvider(providers: [
            BlocProvider<FavoritesTabBloc>(
                create: (_) => FavoritesTabBloc(
                    youtubeRepository: context.read<YoutubeRepository>())
                  ..add(const GetFavorites())),
          ], child: FavoritesTabView());
        });
  }
}

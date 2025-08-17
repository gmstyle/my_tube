import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/ui/views/home/tabs/search/search_view.dart';

class SearchPage extends Page {
  const SearchPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        final youtubeExplodeRepository =
            context.read<YoutubeExplodeRepository>();
        return MultiBlocProvider(providers: [
          BlocProvider<SearchBloc>(
              create: (context) => SearchBloc(
                  youtubeExplodeRepository: youtubeExplodeRepository)),
          BlocProvider<SearchSuggestionCubit>(
              create: (context) => SearchSuggestionCubit(
                  youtubeExplodeRepository: youtubeExplodeRepository)),
        ], child: SearchView());
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/ui/views/search/search_view.dart';

class SearchPage extends Page {
  const SearchPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        final youtubeRepository = context.read<YoutubeRepository>();
        return MultiBlocProvider(providers: [
          BlocProvider<SearchBloc>(
              create: (context) =>
                  SearchBloc(youtubeRepository: youtubeRepository)),
          BlocProvider<SearchSuggestionCubit>(
              create: (context) =>
                  SearchSuggestionCubit(youtubeRepository: youtubeRepository)),
        ], child: SearchView());
      },
    );
  }
}

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/respositories/youtube_repository.dart';

part 'search_suggestion_state.dart';

class SearchSuggestionCubit extends Cubit<SearchSuggestionState> {
  final YoutubeRepository youtubeRepository;
  final Box settingsBox = Hive.box('settings');
  SearchSuggestionCubit({required this.youtubeRepository})
      : super(const SearchSuggestionState(suggestions: []));

  Future<void> getSuggestions(String query) async {
    final response = await youtubeRepository.getSearchSuggestions(query);
    emit(SearchSuggestionState(suggestions: response.suggestions));
  }

  void getQueryHistory() {
    if (settingsBox.containsKey('queryHistory')) {
      final history =
          jsonDecode(settingsBox.get('queryHistory')) as List<dynamic>;
      final queryHistory = history.map((e) => e.toString()).toList();
      emit(SearchSuggestionState(
          suggestions: queryHistory, isQueryHistory: true));
    } else {
      emit(const SearchSuggestionState(suggestions: []));
    }
  }

  void deleteQueryFromHistory(String query) {
    if (settingsBox.containsKey('queryHistory')) {
      final history =
          jsonDecode(settingsBox.get('queryHistory')) as List<dynamic>;
      final queryHistory = history.map((e) => e.toString()).toList();
      queryHistory.remove(query);
      settingsBox.put('queryHistory', jsonEncode(queryHistory));
      emit(SearchSuggestionState(
          suggestions: queryHistory, isQueryHistory: true));
    }
  }
}

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/utils/constants.dart';

part 'search_suggestion_state.dart';

class SearchSuggestionCubit extends Cubit<SearchSuggestionState> {
  final YoutubeExplodeRepository youtubeExplodeRepository;
  final Box settingsBox = Hive.box(hiveSettingsBoxName);
  SearchSuggestionCubit({required this.youtubeExplodeRepository})
      : super(const SearchSuggestionState(suggestions: []));

  Future<void> getSuggestions(String query) async {
    final response = await youtubeExplodeRepository.getSearchSuggestions(query);
    emit(SearchSuggestionState(suggestions: response));
  }

  void getQueryHistory() {
    if (settingsBox.containsKey(settingsQueryHistoryKey)) {
      final history =
          jsonDecode(settingsBox.get(settingsQueryHistoryKey)) as List<dynamic>;
      final queryHistory = history.map((e) => e.toString()).toList();
      emit(SearchSuggestionState(
          suggestions: queryHistory, isQueryHistory: true));
    } else {
      emit(const SearchSuggestionState(suggestions: []));
    }
  }

  void deleteQueryFromHistory(String query) {
    if (settingsBox.containsKey(settingsQueryHistoryKey)) {
      final history =
          jsonDecode(settingsBox.get(settingsQueryHistoryKey)) as List<dynamic>;
      final queryHistory = history.map((e) => e.toString()).toList();
      queryHistory.remove(query);
      settingsBox.put(settingsQueryHistoryKey, jsonEncode(queryHistory));
      emit(SearchSuggestionState(
          suggestions: queryHistory, isQueryHistory: true));
    }
  }
}

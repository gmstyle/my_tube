import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final YoutubeExplodeRepository youtubeExplodeRepository;
  final settingsBox = Hive.box('settings');
  SearchBloc({required this.youtubeExplodeRepository})
      : super(const SearchState.initial()) {
    on<SearchContents>((event, emit) async {
      await _onSearchContents(event, emit);
    });
  }

  Future<void> _onSearchContents(
      SearchContents event, Emitter<SearchState> emit) async {
    emit(const SearchState.loading());
    try {
      final result =
          await youtubeExplodeRepository.searchContents(query: event.query);

      log('Ricerca completata: ${result.length} risorse');

      _saveQueryHistory(event);
      emit(SearchState.success(result));
    } catch (e) {
      emit(SearchState.failure(e.toString()));
    }
  }

  void _saveQueryHistory(SearchContents event) {
    if (settingsBox.containsKey('queryHistory')) {
      final oldHistory =
          jsonDecode(settingsBox.get('queryHistory')) as List<dynamic>;
      if (!oldHistory.contains(event.query)) {
        // aggiungi l'elemento alla lista in testa
        oldHistory.insert(0, event.query);
        // rimuovi l'ultimo elemento se la lista è più lunga di 15 elementi
        if (oldHistory.length > 15) {
          oldHistory.removeLast();
        }
      }
      settingsBox.put('queryHistory', jsonEncode(oldHistory));
    } else {
      settingsBox.put('queryHistory', jsonEncode([event.query]));
    }
  }
}

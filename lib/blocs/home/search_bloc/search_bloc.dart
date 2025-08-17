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
    on<LoadMoreSearchContents>((event, emit) async {
      await _onLoadMore(event, emit);
    });
  }

  Future<void> _onSearchContents(
      SearchContents event, Emitter<SearchState> emit) async {
    emit(const SearchState.loading());
    try {
      final map =
          await youtubeExplodeRepository.searchContents(query: event.query);

      final List<dynamic> items = map['items'] as List<dynamic>;
      final searchList = map['searchList'];

      log('Ricerca completata: ${items.length} risorse');

      _saveQueryHistory(event);
      emit(SearchState.success(items: items, searchList: searchList));
    } catch (e) {
      emit(SearchState.failure(e.toString()));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreSearchContents event, Emitter<SearchState> emit) async {
    final current = state;

    // Only load more if we have a successful result and not already loading
    if (current.status != SearchStatus.success || current.isLoadingMore) return;

    final searchList = current.searchList;
    if (searchList == null) return;

    // set loading-more flag
    emit(current.copyWith(isLoadingMore: true));

    try {
      // repository expects the concrete SearchList type; pass-through opaque object
      final nextItems = await youtubeExplodeRepository
          .nextSearchContents(searchList as dynamic /* SearchList */);

      // if null -> no more results
      if (nextItems == null || nextItems.isEmpty) {
        emit(current.copyWith(isLoadingMore: false));
        return;
      }

      final combined = [...?current.items, ...nextItems];

      emit(current.copyWith(items: combined, isLoadingMore: false));
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

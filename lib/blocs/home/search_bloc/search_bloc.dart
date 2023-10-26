import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/youtube_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final YoutubeRepository youtubeRepository;
  final settingsBox = Hive.box('settings');
  SearchBloc({required this.youtubeRepository})
      : super(const SearchState.initial()) {
    on<SearchContents>((event, emit) async {
      await _onSearchContents(event, emit);
    });

    on<GetNextPageSearchContents>((event, emit) async {
      await _onGetNextPageSearchContents(event, emit);
    });
  }

  Future<void> _onSearchContents(
      SearchContents event, Emitter<SearchState> emit) async {
    emit(const SearchState.loading());
    try {
      final result = await youtubeRepository.searchContents(query: event.query);

      _saveQueryHistory(event);
      emit(SearchState.success(result));
    } catch (e) {
      emit(SearchState.failure(e.toString()));
    }
  }

  Future<void> _onGetNextPageSearchContents(
      GetNextPageSearchContents event, Emitter<SearchState> emit) async {
    try {
      final List<ResourceMT> videos = state.status == SearchStatus.success
          ? state.result!.resources
          : const <ResourceMT>[];

      final result = await youtubeRepository.searchContents(
          query: event.query, nextPageToken: event.nextPageToken);

      final newVideos = result.resources;

      final updatedVideos = [...videos, ...newVideos];
      emit(SearchState.success(ResponseMT(
          resources: updatedVideos, nextPageToken: result.nextPageToken)));
    } catch (e) {
      emit(SearchState.failure(e.toString()));
    }
  }

  void _saveQueryHistory(SearchContents event) {
    if (settingsBox.containsKey('queryHistory')) {
      final oldHistory =
          jsonDecode(settingsBox.get('queryHistory')) as List<dynamic>;
      if (!oldHistory.contains(event.query)) {
        oldHistory.add(event.query);
      }
      settingsBox.put('queryHistory', jsonEncode(oldHistory));
    } else {
      settingsBox.put('queryHistory', jsonEncode([event.query]));
    }
  }
}

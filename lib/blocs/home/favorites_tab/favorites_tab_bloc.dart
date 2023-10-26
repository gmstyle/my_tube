import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/utils/utils.dart';

part 'favorites_tab_event.dart';
part 'favorites_tab_state.dart';

class FavoritesTabBloc extends Bloc<FavoritesTabEvent, FavoritesTabState> {
  final YoutubeRepository youtubeRepository;
  final Box settingsBox = Hive.box('settings');
  FavoritesTabBloc({required this.youtubeRepository})
      : super(const FavoritesTabState.loading()) {
    on<GetFavorites>((event, emit) async {
      await _onGetFavorites(event, emit);
    });

    on<GetNextPageFavorites>((event, emit) async {
      await _onGetNextPageTrendingVideos(event, emit);
    });
  }

  Future<void> _onGetFavorites(
      GetFavorites event, Emitter<FavoritesTabState> emit) async {
    emit(const FavoritesTabState.loading());
    try {
      /// recupero i video della categoria 'Music'
      final musicCategoryId = Utils.getMusicVideoCategoryId(
          jsonDecode(settingsBox.get('categories')));
      final response = await youtubeRepository.getVideos(
          categoryId: musicCategoryId, myRating: 'like');

      emit(FavoritesTabState.loaded(response: response));
    } catch (error) {
      emit(FavoritesTabState.error(error: error.toString()));
    }
  }

  Future<void> _onGetNextPageTrendingVideos(
      GetNextPageFavorites event, Emitter<FavoritesTabState> emit) async {
    try {
      final List<ResourceMT> videos = state.status == FavoritesStatus.success
          ? state.response!.resources
          : const <ResourceMT>[];
      final musicVideoCategoryId = Utils.getMusicVideoCategoryId(
          jsonDecode(settingsBox.get('categories')));
      final response = await youtubeRepository.getVideos(
          nextPageToken: event.nextPageToken,
          categoryId: musicVideoCategoryId,
          myRating: 'like');

      final newVideos = response.resources;

      final updatedVideos = [...videos, ...newVideos];
      emit(FavoritesTabState.loaded(
          response: ResponseMT(
              resources: updatedVideos,
              nextPageToken: response.nextPageToken)));
    } catch (error) {
      emit(FavoritesTabState.error(error: error.toString()));
    }
  }
}

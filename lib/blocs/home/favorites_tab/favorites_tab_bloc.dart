import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/models/video_category_mt.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/respositories/youtube_repository.dart';

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
      final musicCategoryId = getMusicVideoCategoryId();
      final response = await youtubeRepository.getFavoriteVideos(
          categoryId: musicCategoryId);
      emit(FavoritesTabState.loaded(response: response));
    } catch (error) {
      emit(FavoritesTabState.error(error: error.toString()));
    }
  }

  Future<void> _onGetNextPageTrendingVideos(
      GetNextPageFavorites event, Emitter<FavoritesTabState> emit) async {
    try {
      final nextPageToken = event.nextPageToken;
      final List<VideoMT> videos = state.status == FavoritesStatus.success
          ? state.response!.videos
          : const <VideoMT>[];
      final response = await youtubeRepository.getFavoriteVideos(
          nextPageToken: nextPageToken);

      final newVideos = response.videos;

      final updatedVideos = [...videos, ...newVideos];
      emit(FavoritesTabState.loaded(
          response: VideoResponseMT(
              videos: updatedVideos, nextPageToken: response.nextPageToken)));
    } catch (error) {
      emit(FavoritesTabState.error(error: error.toString()));
    }
  }

  String getMusicVideoCategoryId() {
    final categories = jsonDecode(settingsBox.get('categories'));
    final categoriesMT = categories
        .map((category) => VideoCategoryMT.fromJson(category))
        .toList();
    return categoriesMT.firstWhere((element) => element.title == 'Music').id;
  }
}
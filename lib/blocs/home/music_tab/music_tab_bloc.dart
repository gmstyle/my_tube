import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/models/music_home_mt.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/utils/utils.dart';

part 'musci_tab_event.dart';
part 'music_tab_state.dart';

class MusicTabBloc extends Bloc<MusicTabEvent, MusicTabState> {
  final InnertubeRepository innertubeRepository;
  final Box settingsBox = Hive.box('settings');
  MusicTabBloc({required this.innertubeRepository})
      : super(const MusicTabState.loading()) {
    on<GetMusicHome>((event, emit) async {
      await _onGetFavorites(event, emit);
    });

    on<GetNextPageMusic>((event, emit) async {
      await _onGetNextPageTrendingVideos(event, emit);
    });
  }

  Future<void> _onGetFavorites(
      GetMusicHome event, Emitter<MusicTabState> emit) async {
    emit(const MusicTabState.loading());
    try {
      final response = await innertubeRepository.getMusicHome();

      emit(MusicTabState.loaded(response: response));
    } catch (error) {
      emit(MusicTabState.error(error: error.toString()));
    }
  }

  Future<void> _onGetNextPageTrendingVideos(
      GetNextPageMusic event, Emitter<MusicTabState> emit) async {
    /* try {
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
        nextPageToken: response.nextPageToken,
      )));
    } catch (error) {
      emit(FavoritesTabState.error(error: error.toString()));
    } */
  }
}

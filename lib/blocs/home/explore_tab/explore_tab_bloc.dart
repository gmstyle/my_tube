import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:innertube_dart/enums/enums.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/utils/utils.dart';

part 'explore_tab_event.dart';
part 'explore_tab_state.dart';

class ExploreTabBloc extends Bloc<ExploreTabEvent, ExploreTabState> {
  final InnertubeRepository innertubeRepository;
  final Box settingsBox = Hive.box('settings');
  ExploreTabBloc({required this.innertubeRepository})
      : super(const ExploreTabState.loading()) {
    on<GetTrendingVideos>((event, emit) async {
      await _onGetTrendingVideos(event, emit);
    });

    on<GetNextPageTrendingVideos>((event, emit) async {
      await _onGetNextPageTrendingVideos(event, emit);
    });
  }

  Future<void> _onGetTrendingVideos(
      GetTrendingVideos event, Emitter<ExploreTabState> emit) async {
    emit(const ExploreTabState.loading());
    TrendingCategory trendingCategory = TrendingCategory.now;
    try {
      switch (event.category) {
        case 'now':
          trendingCategory = TrendingCategory.now;
          break;
        case 'music':
          trendingCategory = TrendingCategory.music;
          break;
        case 'film':
          trendingCategory = TrendingCategory.film;
          break;
        case 'gaming':
          trendingCategory = TrendingCategory.gaming;
          break;
      }
      final response = await innertubeRepository.getTrending(trendingCategory);
      emit(ExploreTabState.loaded(response: response));
    } catch (error) {
      emit(ExploreTabState.error(error: error.toString()));
    }
  }

  Future<void> _onGetNextPageTrendingVideos(
      GetNextPageTrendingVideos event, Emitter<ExploreTabState> emit) async {
    /* try {
      final List<ResourceMT> videos = state.status == YoutubeStatus.loaded
          ? state.response!.resources
          : const <ResourceMT>[];
      final musicVideoCategoryId = Utils.getMusicVideoCategoryId(
          jsonDecode(settingsBox.get('categories')));
      final response = await innertubeRepository.getVideos(
          nextPageToken: event.nextPageToken,
          categoryId: musicVideoCategoryId,
          chart: 'mostPopular');

      final newVideos = response.resources;

      final updatedVideos = [...videos, ...newVideos];
      emit(ExploreTabState.loaded(
          response: ResponseMT(
        resources: updatedVideos,
        nextPageToken: response.nextPageToken,
      )));
    } catch (error) {
      emit(ExploreTabState.error(error: error.toString()));
    } */
  }
}

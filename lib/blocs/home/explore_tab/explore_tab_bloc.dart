import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:innertube_dart/enums/enums.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/ui/views/home/tabs/explore_tab_view.dart';

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
  }

  Future<void> _onGetTrendingVideos(
      GetTrendingVideos event, Emitter<ExploreTabState> emit) async {
    emit(const ExploreTabState.loading());
    TrendingCategory trendingCategory = TrendingCategory.now;
    try {
      switch (event.category) {
        case CategoryEnum.now:
          trendingCategory = TrendingCategory.now;
          break;
        case CategoryEnum.music:
          trendingCategory = TrendingCategory.music;
          break;
        case CategoryEnum.film:
          trendingCategory = TrendingCategory.film;
          break;
        case CategoryEnum.gaming:
          trendingCategory = TrendingCategory.gaming;
          break;
      }
      final response = await innertubeRepository.getTrending(trendingCategory);
      emit(ExploreTabState.loaded(response: response));
    } catch (error) {
      emit(ExploreTabState.error(error: error.toString()));
    }
  }
}

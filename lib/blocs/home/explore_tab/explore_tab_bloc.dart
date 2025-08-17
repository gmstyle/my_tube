import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/ui/views/home/tabs/explore_tab_view.dart';

part 'explore_tab_event.dart';
part 'explore_tab_state.dart';

class ExploreTabBloc extends Bloc<ExploreTabEvent, ExploreTabState> {
  final YoutubeExplodeRepository youtubeExplodeRepository;
  final Box settingsBox = Hive.box('settings');
  ExploreTabBloc({required this.youtubeExplodeRepository})
      : super(const ExploreTabState.loading()) {
    on<GetTrendingVideos>((event, emit) async {
      await _onGetTrendingVideos(event, emit);
    });
  }

  Future<void> _onGetTrendingVideos(
      GetTrendingVideos event, Emitter<ExploreTabState> emit) async {
    emit(const ExploreTabState.loading());
    String trendingCategory = 'now';
    try {
      switch (event.category) {
        case CategoryEnum.now:
          trendingCategory = 'now';
          break;
        case CategoryEnum.music:
          trendingCategory = 'music';
          break;
        case CategoryEnum.film:
          trendingCategory = 'film';
          break;
        case CategoryEnum.gaming:
          trendingCategory = 'gaming';
          break;
      }
      final response =
          await youtubeExplodeRepository.getTrending(trendingCategory);
      emit(ExploreTabState.loaded(response: response));
    } catch (error) {
      emit(ExploreTabState.error(error: error.toString()));
    }
  }
}

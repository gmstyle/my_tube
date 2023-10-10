import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/respositories/youtube_repository.dart';

part 'explore_tab_event.dart';
part 'explore_tab_state.dart';

class ExploreTabBloc extends Bloc<ExploreTabEvent, ExploreTabState> {
  final YoutubeRepository youtubeRepository;
  ExploreTabBloc({required this.youtubeRepository})
      : super(const ExploreTabState.loading()) {
    on<GetVideos>((event, emit) async {
      await _onGetVideos(event, emit);
    });

    on<GetNextPageVideos>((event, emit) async {
      await _onGetNextPageVideos(event, emit);
    });
  }

  Future<void> _onGetVideos(
      GetVideos event, Emitter<ExploreTabState> emit) async {
    emit(const ExploreTabState.loading());
    try {
      final response = await youtubeRepository.getVideos();
      emit(ExploreTabState.loaded(response: response));
    } catch (error) {
      emit(ExploreTabState.error(error: error.toString()));
    }
  }

  Future<void> _onGetNextPageVideos(
      GetNextPageVideos event, Emitter<ExploreTabState> emit) async {
    try {
      final nextPageToken = event.nextPageToken;
      final List<VideoMT> videos = state.status == YoutubeStatus.loaded
          ? state.response!.videos
          : const <VideoMT>[];
      final response =
          await youtubeRepository.getVideos(nextPageToken: nextPageToken);

      final newVideos = response.videos;

      final updatedVideos = [...videos, ...newVideos];
      emit(ExploreTabState.loaded(
          response: VideoResponse(
              videos: updatedVideos, nextPageToken: response.nextPageToken)));
    } catch (error) {
      emit(ExploreTabState.error(error: error.toString()));
    }
  }
}

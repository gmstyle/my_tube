import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/respositories/youtube_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final YoutubeRepository youtubeRepository;
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
      emit(SearchState.success(result));
    } catch (e) {
      emit(SearchState.failure(e.toString()));
    }
  }

  Future<void> _onGetNextPageSearchContents(
      GetNextPageSearchContents event, Emitter<SearchState> emit) async {
    try {
      final List<VideoMT> videos = state.status == SearchStatus.success
          ? state.result!.videos
          : const <VideoMT>[];

      final result = await youtubeRepository.searchContents(
          query: event.query, nextPageToken: event.nextPageToken);

      final newVideos = result.videos;

      final updatedVideos = [...videos, ...newVideos];
      emit(SearchState.success(VideoResponseMT(
          videos: updatedVideos, nextPageToken: result.nextPageToken)));
    } catch (e) {
      emit(SearchState.failure(e.toString()));
    }
  }
}

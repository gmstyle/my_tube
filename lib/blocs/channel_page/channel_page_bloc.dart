import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/models/tiles.dart';

part 'channel_page_event.dart';
part 'channel_page_state.dart';

class ChannelPageBloc extends Bloc<ChannelPageEvent, ChannelPageState> {
  final YoutubeExplodeRepository youtubeExplodeRepository;

  ChannelPageBloc({required this.youtubeExplodeRepository})
      : super(const ChannelPageState.initial()) {
    on<GetChannelDetails>((event, emit) async {
      await _onGetChannelDetails(event, emit);
    });

    on<LoadMoreChannelVideos>((event, emit) async {
      await _onLoadMoreChannelVideos(event, emit);
    });
  }

  Future<void> _onGetChannelDetails(
      GetChannelDetails event, Emitter<ChannelPageState> emit) async {
    emit(const ChannelPageState.loading());
    try {
      final channelDetails =
          await youtubeExplodeRepository.getChannel(event.channelId);

      // channelDetails contains 'channel', 'videos' and 'uploadsList'
      final videos = channelDetails['videos'] as List<dynamic>?;
      final uploadsList = channelDetails['uploadsList'];

      emit(ChannelPageState.loaded(channelDetails,
          items: videos, uploadsList: uploadsList));
    } catch (e) {
      emit(const ChannelPageState.failure(error: 'Failed to load channel'));
    }
  }

  Future<void> _onLoadMoreChannelVideos(
      LoadMoreChannelVideos event, Emitter<ChannelPageState> emit) async {
    final current = state;

    if (current.status != ChannelPageStatus.loaded || current.isLoadingMore) {
      return;
    }

    final uploadsList = current.uploadsList;
    if (uploadsList == null) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final next = await youtubeExplodeRepository
          .nextChannelVideos(uploadsList as dynamic /* ChannelUploadsList */);

      if (next == null || next.isEmpty) {
        emit(current.copyWith(isLoadingMore: false));
        return;
      }

      // The repository's nextChannelVideos returns List<Video>. Convert to VideoTile here:
      final nextVideoTiles = next.map((v) => VideoTile.fromVideo(v)).toList();

      final combined = [...?current.items, ...nextVideoTiles];

      emit(current.copyWith(items: combined, isLoadingMore: false));
    } catch (e) {
      emit(ChannelPageState.failure(error: 'Failed to load more videos'));
    }
  }
}

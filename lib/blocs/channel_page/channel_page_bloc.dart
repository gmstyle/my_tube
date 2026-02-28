import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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

    on<LoadChannelShorts>((event, emit) async {
      await _onLoadChannelShorts(event, emit);
    });

    on<LoadMoreChannelShorts>((event, emit) async {
      await _onLoadMoreChannelShorts(event, emit);
    });

    on<LoadChannelPlaylists>((event, emit) async {
      await _onLoadChannelPlaylists(event, emit);
    });

    on<LoadMoreChannelPlaylists>((event, emit) async {
      await _onLoadMoreChannelPlaylists(event, emit);
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

      final nextVideoTiles = next.map((v) => VideoTile.fromVideo(v)).toList();
      final combined = [...?current.items, ...nextVideoTiles];

      emit(current.copyWith(items: combined, isLoadingMore: false));
    } catch (e) {
      emit(current.copyWith(
          isLoadingMore: false, error: 'Failed to load more videos'));
    }
  }

  Future<void> _onLoadChannelShorts(
      LoadChannelShorts event, Emitter<ChannelPageState> emit) async {
    final current = state;
    if (current.isLoadingShorts || current.shorts != null) return;

    emit(current.copyWith(isLoadingShorts: true));
    try {
      final result =
          await youtubeExplodeRepository.getChannelShorts(event.channelId);
      final shorts = result['shorts'] as List<dynamic>?;
      final shortsList = result['shortsList'];
      emit(current.copyWith(
        shorts: shorts ?? [],
        shortsList: shortsList,
        isLoadingShorts: false,
      ));
    } catch (e) {
      emit(current.copyWith(
        shorts: [],
        isLoadingShorts: false,
      ));
    }
  }

  Future<void> _onLoadMoreChannelShorts(
      LoadMoreChannelShorts event, Emitter<ChannelPageState> emit) async {
    final current = state;
    if (current.isLoadingMoreShorts || current.shortsList == null) return;

    emit(current.copyWith(isLoadingMoreShorts: true));
    try {
      final nextPage = await youtubeExplodeRepository
          .nextChannelShorts(current.shortsList as ChannelUploadsList);
      if (nextPage == null || nextPage.isEmpty) {
        emit(current.copyWith(isLoadingMoreShorts: false));
        return;
      }
      final nextTiles = nextPage.map((v) => VideoTile.fromVideo(v)).toList();
      final combined = [...?current.shorts, ...nextTiles];
      emit(current.copyWith(
          shorts: combined,
          shortsList: nextPage, // store new paginator
          isLoadingMoreShorts: false));
    } catch (e) {
      emit(current.copyWith(isLoadingMoreShorts: false));
    }
  }

  Future<void> _onLoadChannelPlaylists(
      LoadChannelPlaylists event, Emitter<ChannelPageState> emit) async {
    final current = state;
    if (current.isLoadingPlaylists || current.playlists != null) return;

    emit(current.copyWith(isLoadingPlaylists: true));
    try {
      final result = await youtubeExplodeRepository
          .getChannelPlaylists(event.channelTitle);
      final playlists = result['playlists'] as List<dynamic>?;
      final playlistsList = result['playlistsList'];
      emit(current.copyWith(
        playlists: playlists ?? [],
        playlistsList: playlistsList,
        isLoadingPlaylists: false,
      ));
    } catch (e) {
      emit(current.copyWith(
        playlists: [],
        isLoadingPlaylists: false,
      ));
    }
  }

  Future<void> _onLoadMoreChannelPlaylists(
      LoadMoreChannelPlaylists event, Emitter<ChannelPageState> emit) async {
    final current = state;
    if (current.isLoadingMorePlaylists || current.playlistsList == null) return;

    emit(current.copyWith(isLoadingMorePlaylists: true));
    try {
      final next = await youtubeExplodeRepository
          .nextChannelPlaylists(current.playlistsList as SearchList);
      if (next == null || next.isEmpty) {
        emit(current.copyWith(isLoadingMorePlaylists: false));
        return;
      }
      final combined = [...?current.playlists, ...next];
      emit(
          current.copyWith(playlists: combined, isLoadingMorePlaylists: false));
    } catch (e) {
      emit(current.copyWith(isLoadingMorePlaylists: false));
    }
  }
}

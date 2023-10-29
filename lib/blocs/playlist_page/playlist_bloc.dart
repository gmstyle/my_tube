import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/youtube_repository.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final YoutubeRepository youtubeRepository;

  PlaylistBloc({required this.youtubeRepository})
      : super(const PlaylistState.initial()) {
    on<GetPlaylist>((event, emit) async {
      await _onGetPlaylist(event, emit);
    });
  }

  Future<void> _onGetPlaylist(
      GetPlaylist event, Emitter<PlaylistState> emit) async {
    emit(const PlaylistState.loading());
    try {
      final response = await youtubeRepository.getPlaylistItems(
        playlistId: event.playlistId,
      );
      final videoIds = response.resources.map((e) => e.id!).toList();
      emit(PlaylistState.success(response, videoIds));
    } catch (e) {
      emit(PlaylistState.failure(e.toString()));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/playlist_mt.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final YoutubeExplodeRepository youtubeExplodeRepository;

  PlaylistBloc({required this.youtubeExplodeRepository})
      : super(const PlaylistState.initial()) {
    on<GetPlaylist>((event, emit) async {
      await _onGetPlaylist(event, emit);
    });
  }

  Future<void> _onGetPlaylist(
      GetPlaylist event, Emitter<PlaylistState> emit) async {
    emit(const PlaylistState.loading());
    try {
      final response = await youtubeExplodeRepository.getPlaylist(
        event.playlistId,
      );
      emit(PlaylistState.success(response));
    } catch (e) {
      emit(PlaylistState.failure(e.toString()));
    }
  }
}

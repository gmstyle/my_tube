import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/custom_playlists/custom_playlists_state.dart';
import 'package:my_tube/respositories/custom_playlist_repository.dart';

class CustomPlaylistsCubit extends Cubit<CustomPlaylistsState> {
  final CustomPlaylistRepository repository;

  CustomPlaylistsCubit({required this.repository}) : super(const CustomPlaylistsState()) {
    _initListen();
  }

  void _initListen() {
    repository.customPlaylistsListenable.addListener(_onPlaylistsChanged);
    _loadPlaylists();
  }

  void _onPlaylistsChanged() {
    _loadPlaylists();
  }

  void _loadPlaylists() {
    try {
      if (state.status == CustomPlaylistsStatus.initial) {
        emit(state.copyWith(status: CustomPlaylistsStatus.loading));
      }
      final playlists = repository.getPlaylists();
      emit(state.copyWith(
        status: CustomPlaylistsStatus.success,
        playlists: playlists,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CustomPlaylistsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> createPlaylist(String title) async {
    await repository.createPlaylist(title);
  }

  Future<void> deletePlaylist(String id) async {
    await repository.deletePlaylist(id);
  }

  Future<void> updatePlaylistTitle(String id, String newTitle) async {
    await repository.updatePlaylistTitle(id, newTitle);
  }

  Future<void> addVideoToPlaylist(String playlistId, String videoId) async {
    await repository.addVideoToPlaylist(playlistId, videoId);
  }

  Future<void> removeVideoFromPlaylist(String playlistId, String videoId) async {
    await repository.removeVideoFromPlaylist(playlistId, videoId);
  }

  @override
  Future<void> close() {
    repository.customPlaylistsListenable.removeListener(_onPlaylistsChanged);
    return super.close();
  }
}


import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/respositories/favorite_repository.dart';

part 'favorites_playlist_event.dart';
part 'favorites_playlist_state.dart';

class FavoritesPlaylistBloc
    extends Bloc<FavoritesPlaylistEvent, FavoritesPlaylistState> {
  final FavoriteRepository favoritesRepository;

  FavoritesPlaylistBloc({required this.favoritesRepository})
      : super(const FavoritesPlaylistState.initial()) {
    favoritesRepository.favoritePlaylistsListenable.addListener(() {
      add(const GetFavoritesPlaylist());
    });

    on<GetFavoritesPlaylist>((event, emit) async {
      await _onGetFavoritesPlaylist(event, emit);
    });

    on<AddToFavoritesPlaylist>((event, emit) async {
      await _onAddToFavoritesPlaylist(event, emit);
    });

    on<RemoveFromFavoritesPlaylist>((event, emit) async {
      await _onRemoveFromFavoritesPlaylist(event, emit);
    });

    on<ClearFavoritesPlaylist>((event, emit) async {
      await _onClearFavoritesPlaylist(event, emit);
    });
  }

  Future<void> _onGetFavoritesPlaylist(
      GetFavoritesPlaylist event, Emitter<FavoritesPlaylistState> emit) async {
    emit(const FavoritesPlaylistState.loading());
    try {
      final favorites = await favoritesRepository.favoritePlaylists;
      emit(FavoritesPlaylistState.success(favorites));
    } catch (e) {
      emit(FavoritesPlaylistState.failure(e.toString()));
    }
  }

  Future<void> _onAddToFavoritesPlaylist(AddToFavoritesPlaylist event,
      Emitter<FavoritesPlaylistState> emit) async {
    try {
      await favoritesRepository.addPlaylist(event.playlistId);
      final favorites = await favoritesRepository.favoritePlaylists;
      emit(FavoritesPlaylistState.success(favorites));
    } catch (e) {
      emit(FavoritesPlaylistState.failure(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavoritesPlaylist(RemoveFromFavoritesPlaylist event,
      Emitter<FavoritesPlaylistState> emit) async {
    try {
      await favoritesRepository.removePlaylist(event.id);
      final favorites = await favoritesRepository.favoritePlaylists;
      emit(FavoritesPlaylistState.success(favorites));
    } catch (e) {
      emit(FavoritesPlaylistState.failure(e.toString()));
    }
  }

  Future<void> _onClearFavoritesPlaylist(ClearFavoritesPlaylist event,
      Emitter<FavoritesPlaylistState> emit) async {
    try {
      await favoritesRepository.clearPlaylists();
      final favorites = await favoritesRepository.favoritePlaylists;
      emit(FavoritesPlaylistState.success(favorites));
    } catch (e) {
      emit(FavoritesPlaylistState.failure(e.toString()));
    }
  }
}

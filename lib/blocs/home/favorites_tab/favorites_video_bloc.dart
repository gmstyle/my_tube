import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/respositories/favorite_repository.dart';

part 'favorites_video_event.dart';
part 'favorites_video_state.dart';

class FavoritesVideoBloc
    extends Bloc<FavoritesVideoEvent, FavoritesVideoState> {
  final FavoriteRepository favoritesRepository;
  FavoritesVideoBloc({
    required this.favoritesRepository,
  }) : super(const FavoritesVideoState.initial()) {
    // ascolto il cambiamento della coda e aggiorno lo stato
    // quando viene aggiunto o rimosso un video
    favoritesRepository.favoriteVideosListenable.addListener(() {
      add(const GetFavorites());
    });

    on<GetFavorites>((event, emit) async {
      await _onGetFavorites(event, emit);
    });

    on<AddToFavorites>((event, emit) async {
      await _onAddToFavorites(event, emit);
    });

    on<RemoveFromFavorites>((event, emit) async {
      await _onRemoveFromFavorites(event, emit);
    });

    on<ClearFavorites>((event, emit) async {
      await _onClearFavorites(event, emit);
    });
  }

  Future<void> _onGetFavorites(
      FavoritesVideoEvent event, Emitter<FavoritesVideoState> emit) async {
    emit(const FavoritesVideoState.loading());
    try {
      final favorites = await favoritesRepository.favoriteVideos;
      emit(FavoritesVideoState.success(favorites));
    } catch (e) {
      emit(FavoritesVideoState.failure(e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
      AddToFavorites event, Emitter<FavoritesVideoState> emit) async {
    emit(const FavoritesVideoState.loading());
    try {
      await favoritesRepository.addVideo(event.videoId);
      final favorites = await favoritesRepository.favoriteVideos;

      emit(FavoritesVideoState.success(favorites));
    } catch (e) {
      emit(FavoritesVideoState.failure(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorites(
      RemoveFromFavorites event, Emitter<FavoritesVideoState> emit) async {
    emit(const FavoritesVideoState.loading());
    try {
      await favoritesRepository.removeVideo(event.id);
      final favorites = await favoritesRepository.favoriteVideos;

      emit(FavoritesVideoState.success(favorites));
    } catch (e) {
      emit(FavoritesVideoState.failure(e.toString()));
    }
  }

  Future<void> _onClearFavorites(
      ClearFavorites event, Emitter<FavoritesVideoState> emit) async {
    emit(const FavoritesVideoState.loading());
    try {
      await favoritesRepository.clearVideos();
      final favorites = await favoritesRepository.favoriteVideos;

      emit(FavoritesVideoState.success(favorites));
    } catch (e) {
      emit(FavoritesVideoState.failure(e.toString()));
    }
  }
}

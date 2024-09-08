import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/respositories/favorite_repository.dart';
import 'package:my_tube/utils/enums.dart';

part 'favorites_video_event.dart';
part 'favorites_video_state.dart';

class FavoritesVideoBloc
    extends Bloc<FavoritesVideoEvent, FavoritesVideoState> {
  final FavoriteRepository favoritesRepository;
  final InnertubeRepository innertubeRepository;
  FavoritesVideoBloc({
    required this.favoritesRepository,
    required this.innertubeRepository,
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
      final favorites = favoritesRepository.favoriteVideos;
      emit(FavoritesVideoState.success(favorites));
    } catch (e) {
      emit(FavoritesVideoState.failure(e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
      AddToFavorites event, Emitter<FavoritesVideoState> emit) async {
    emit(const FavoritesVideoState.loading());
    try {
      await favoritesRepository.add(event.video, Kind.video);
      final favorites = favoritesRepository.favoriteVideos;

      emit(FavoritesVideoState.success(favorites));
    } catch (e) {
      emit(FavoritesVideoState.failure(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorites(
      RemoveFromFavorites event, Emitter<FavoritesVideoState> emit) async {
    emit(const FavoritesVideoState.loading());
    try {
      await favoritesRepository.remove(event.id, Kind.video);
      final favorites = favoritesRepository.favoriteVideos;

      emit(FavoritesVideoState.success(favorites));
    } catch (e) {
      emit(FavoritesVideoState.failure(e.toString()));
    }
  }

  Future<void> _onClearFavorites(
      ClearFavorites event, Emitter<FavoritesVideoState> emit) async {
    emit(const FavoritesVideoState.loading());
    try {
      await favoritesRepository.clear(Kind.video);
      final favorites = favoritesRepository.favoriteVideos;

      emit(FavoritesVideoState.success(favorites));
    } catch (e) {
      emit(FavoritesVideoState.failure(e.toString()));
    }
  }
}

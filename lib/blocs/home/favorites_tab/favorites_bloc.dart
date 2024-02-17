import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/respositories/favorite_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoriteRepository favoritesRepository;
  final InnertubeRepository innertubeRepository;
  FavoritesBloc({
    required this.favoritesRepository,
    required this.innertubeRepository,
  }) : super(const FavoritesState.initial()) {
    // ascolto il cambiamento della coda e aggiorno lo stato
    // quando viene aggiunto o rimosso un video
    favoritesRepository.favoriteVideosListenable.addListener(() {
      add(const GetFavorites(kind: 'video'));
    });

    favoritesRepository.favoriteChannelsListenable.addListener(() {
      add(const GetFavorites(kind: 'channel'));
    });

    favoritesRepository.favoritePlaylistsListenable.addListener(() {
      add(const GetFavorites(kind: 'playlist'));
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
      FavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(const FavoritesState.loading());
    try {
      List<ResourceMT> favorites = [];
      if (event.kind == 'video') {
        favorites = favoritesRepository.favoriteVideos;
      } else if (event.kind == 'channel') {
        favorites = favoritesRepository.favoriteChannels;
      } else if (event.kind == 'playlist') {
        favorites = favoritesRepository.favoritePlaylists;
      }

      emit(FavoritesState.success(favorites));
    } catch (e) {
      emit(FavoritesState.failure(e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
      AddToFavorites event, Emitter<FavoritesState> emit) async {
    emit(const FavoritesState.loading());
    try {
      List<ResourceMT> favorites = [];
      if (event.kind == 'video') {
        await favoritesRepository.add(event.video, event.kind);
        favorites = favoritesRepository.favoriteVideos;
      } else if (event.kind == 'channel') {
        await favoritesRepository.add(event.video, event.kind);
        favorites = favoritesRepository.favoriteChannels;
      } else if (event.kind == 'playlist') {
        await favoritesRepository.add(event.video, event.kind);
        favorites = favoritesRepository.favoritePlaylists;
      }
      emit(FavoritesState.success(favorites));
    } catch (e) {
      emit(FavoritesState.failure(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorites(
      RemoveFromFavorites event, Emitter<FavoritesState> emit) async {
    emit(const FavoritesState.loading());
    try {
      List<ResourceMT> favorites = [];
      if (event.kind == 'video') {
        await favoritesRepository.remove(event.id, event.kind);
        favorites = favoritesRepository.favoriteVideos;
      } else if (event.kind == 'channel') {
        await favoritesRepository.remove(event.id, event.kind);
        favorites = favoritesRepository.favoriteChannels;
      } else if (event.kind == 'playlist') {
        await favoritesRepository.remove(event.id, event.kind);
        favorites = favoritesRepository.favoritePlaylists;
      }
      emit(FavoritesState.success(favorites));
    } catch (e) {
      emit(FavoritesState.failure(e.toString()));
    }
  }

  Future<void> _onClearFavorites(
      ClearFavorites event, Emitter<FavoritesState> emit) async {
    emit(const FavoritesState.loading());
    try {
      List<ResourceMT> favorites = [];
      if (event.kind == 'video') {
        await favoritesRepository.clear(event.kind);
        favorites = favoritesRepository.favoriteVideos;
      } else if (event.kind == 'channel') {
        await favoritesRepository.clear(event.kind);
        favorites = favoritesRepository.favoriteChannels;
      } else if (event.kind == 'playlist') {
        await favoritesRepository.clear(event.kind);
        favorites = favoritesRepository.favoritePlaylists;
      }
      emit(FavoritesState.success(favorites));
    } catch (e) {
      emit(FavoritesState.failure(e.toString()));
    }
  }
}

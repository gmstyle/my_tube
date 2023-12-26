import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/respositories/favorites_repository.dart';
import 'package:my_tube/services/mt_player_handler.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository favoritesRepository;
  final InnertubeRepository innertubeRepository;
  FavoritesBloc({
    required this.favoritesRepository,
    required this.innertubeRepository,
  }) : super(const FavoritesState.initial()) {
    // ascolto il cambiamento della coda e aggiorno lo stato
    // quando viene aggiunto o rimosso un video
    favoritesRepository.queueListenable.addListener(() {
      add(GetFavorites());
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
      FavoritesEvent event, Emitter<FavoritesState> emit) async {}

  Future<void> _onAddToFavorites(
      FavoritesEvent event, Emitter<FavoritesState> emit) async {}

  Future<void> _onRemoveFromFavorites(
      FavoritesEvent event, Emitter<FavoritesState> emit) async {}

  Future<void> _onClearFavorites(
      FavoritesEvent event, Emitter<FavoritesState> emit) async {}
}

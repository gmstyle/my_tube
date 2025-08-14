import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/respositories/favorite_repository.dart';

part 'favorites_channel_event.dart';
part 'favorites_channel_state.dart';

class FavoritesChannelBloc
    extends Bloc<FavoritesChannelEvent, FavoritesChannelState> {
  final FavoriteRepository favoritesRepository;

  FavoritesChannelBloc({required this.favoritesRepository})
      : super(const FavoritesChannelState.initial()) {
    favoritesRepository.favoriteChannelsListenable.addListener(() {
      add(const GetFavoritesChannel());
    });

    on<GetFavoritesChannel>((event, emit) async {
      await _onGetFavoritesChannel(event, emit);
    });

    on<AddToFavoritesChannel>((event, emit) async {
      await _onAddToFavoritesChannel(event, emit);
    });

    on<RemoveFromFavoritesChannel>((event, emit) async {
      await _onRemoveFromFavoritesChannel(event, emit);
    });

    on<ClearFavoritesChannel>((event, emit) async {
      await _onClearFavoritesChannel(event, emit);
    });
  }

  Future<void> _onGetFavoritesChannel(
      GetFavoritesChannel event, Emitter<FavoritesChannelState> emit) async {
    emit(const FavoritesChannelState.loading());
    try {
      final favorites = await favoritesRepository.favoriteChannels;
      emit(FavoritesChannelState.success(favorites));
    } catch (e) {
      emit(FavoritesChannelState.failure(e.toString()));
    }
  }

  Future<void> _onAddToFavoritesChannel(
      AddToFavoritesChannel event, Emitter<FavoritesChannelState> emit) async {
    try {
      await favoritesRepository.addChannel(event.channelId);
      final favorites = await favoritesRepository.favoriteChannels;
      emit(FavoritesChannelState.success(favorites));
    } catch (e) {
      emit(FavoritesChannelState.failure(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavoritesChannel(RemoveFromFavoritesChannel event,
      Emitter<FavoritesChannelState> emit) async {
    try {
      await favoritesRepository.removeChannel(event.id);
      final favorites = await favoritesRepository.favoriteChannels;
      emit(FavoritesChannelState.success(favorites));
    } catch (e) {
      emit(FavoritesChannelState.failure(e.toString()));
    }
  }

  Future<void> _onClearFavoritesChannel(
      ClearFavoritesChannel event, Emitter<FavoritesChannelState> emit) async {
    try {
      await favoritesRepository.clearChannels();
      final favorites = await favoritesRepository.favoriteChannels;
      emit(FavoritesChannelState.success(favorites));
    } catch (e) {
      emit(FavoritesChannelState.failure(e.toString()));
    }
  }
}

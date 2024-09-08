import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/favorite_repository.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/utils/enums.dart';

part 'favorites_channel_event.dart';
part 'favorites_channel_state.dart';

class FavoritesChannelBloc
    extends Bloc<FavoritesChannelEvent, FavoritesChannelState> {
  final FavoriteRepository favoritesRepository;
  final InnertubeRepository innertubeRepository;

  FavoritesChannelBloc(
      {required this.favoritesRepository, required this.innertubeRepository})
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
      final favorites = favoritesRepository.favoriteChannels;
      emit(FavoritesChannelState.success(favorites));
    } catch (e) {
      emit(FavoritesChannelState.failure(e.toString()));
    }
  }

  Future<void> _onAddToFavoritesChannel(
      AddToFavoritesChannel event, Emitter<FavoritesChannelState> emit) async {
    try {
      await favoritesRepository.add(event.channel, Kind.channel);
      final favorites = favoritesRepository.favoriteChannels;
      emit(FavoritesChannelState.success(favorites));
    } catch (e) {
      emit(FavoritesChannelState.failure(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavoritesChannel(RemoveFromFavoritesChannel event,
      Emitter<FavoritesChannelState> emit) async {
    try {
      await favoritesRepository.remove(event.id, Kind.channel);
      final favorites = favoritesRepository.favoriteChannels;
      emit(FavoritesChannelState.success(favorites));
    } catch (e) {
      emit(FavoritesChannelState.failure(e.toString()));
    }
  }

  Future<void> _onClearFavoritesChannel(
      ClearFavoritesChannel event, Emitter<FavoritesChannelState> emit) async {
    try {
      await favoritesRepository.clear(Kind.channel);
      final favorites = favoritesRepository.favoriteChannels;
      emit(FavoritesChannelState.success(favorites));
    } catch (e) {
      emit(FavoritesChannelState.failure(e.toString()));
    }
  }
}

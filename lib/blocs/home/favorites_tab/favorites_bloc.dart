import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(const FavoritesState.initial()) {
    on<FavoritesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

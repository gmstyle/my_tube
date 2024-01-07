part of 'favorites_bloc.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class GetFavorites extends FavoritesEvent {}

class AddToFavorites extends FavoritesEvent {
  final ResourceMT video;

  const AddToFavorites(this.video);

  @override
  List<Object> get props => [video];
}

class RemoveFromFavorites extends FavoritesEvent {
  final String id;

  const RemoveFromFavorites(this.id);

  @override
  List<Object> get props => [id];
}

class ClearFavorites extends FavoritesEvent {}

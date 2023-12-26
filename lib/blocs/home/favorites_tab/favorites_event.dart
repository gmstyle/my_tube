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
  final ResourceMT video;

  const RemoveFromFavorites(this.video);

  @override
  List<Object> get props => [video];
}

class ClearFavorites extends FavoritesEvent {}

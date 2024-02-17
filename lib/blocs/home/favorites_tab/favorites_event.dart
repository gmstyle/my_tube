part of 'favorites_bloc.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent({required this.kind});

  final String kind;

  @override
  List<Object> get props => [kind];
}

class GetFavorites extends FavoritesEvent {
  const GetFavorites({required super.kind});
}

class AddToFavorites extends FavoritesEvent {
  final ResourceMT video;

  const AddToFavorites(this.video, {required super.kind});

  @override
  List<Object> get props => [video];
}

class RemoveFromFavorites extends FavoritesEvent {
  final String id;

  const RemoveFromFavorites(this.id, {required super.kind});

  @override
  List<Object> get props => [id];
}

class ClearFavorites extends FavoritesEvent {
  const ClearFavorites({required super.kind});
}

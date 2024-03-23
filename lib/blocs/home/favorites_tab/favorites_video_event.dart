part of 'favorites_video_bloc.dart';

sealed class FavoritesVideoEvent extends Equatable {
  const FavoritesVideoEvent();

  @override
  List<Object> get props => [];
}

class GetFavorites extends FavoritesVideoEvent {
  const GetFavorites();
}

class AddToFavorites extends FavoritesVideoEvent {
  final ResourceMT video;

  const AddToFavorites(this.video);

  @override
  List<Object> get props => [video];
}

class RemoveFromFavorites extends FavoritesVideoEvent {
  final String id;

  const RemoveFromFavorites(this.id);

  @override
  List<Object> get props => [id];
}

class ClearFavorites extends FavoritesVideoEvent {
  const ClearFavorites();
}

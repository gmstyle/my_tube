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
  final String videoId;

  const AddToFavorites(this.videoId);

  @override
  List<Object> get props => [videoId];
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

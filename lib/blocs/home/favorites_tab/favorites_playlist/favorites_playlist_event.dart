part of 'favorites_playlist_bloc.dart';

sealed class FavoritesPlaylistEvent extends Equatable {
  const FavoritesPlaylistEvent();

  @override
  List<Object> get props => [];
}

class GetFavoritesPlaylist extends FavoritesPlaylistEvent {
  const GetFavoritesPlaylist();
}

class AddToFavoritesPlaylist extends FavoritesPlaylistEvent {
  final String playlistId;

  const AddToFavoritesPlaylist(this.playlistId);

  @override
  List<Object> get props => [playlistId];
}

class RemoveFromFavoritesPlaylist extends FavoritesPlaylistEvent {
  final String id;

  const RemoveFromFavoritesPlaylist(this.id);

  @override
  List<Object> get props => [id];
}

class ClearFavoritesPlaylist extends FavoritesPlaylistEvent {
  const ClearFavoritesPlaylist();
}

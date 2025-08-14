part of 'favorites_playlist_bloc.dart';

enum FavoritesPlaylistStatus { initial, loading, success, failure }

class FavoritesPlaylistState extends Equatable {
  const FavoritesPlaylistState._(
      {required this.status, this.playlists, this.error});

  final FavoritesPlaylistStatus status;
  final List<PlaylistTile>? playlists;
  final String? error;

  const FavoritesPlaylistState.initial()
      : this._(status: FavoritesPlaylistStatus.initial);

  const FavoritesPlaylistState.loading()
      : this._(status: FavoritesPlaylistStatus.loading);

  const FavoritesPlaylistState.success(List<PlaylistTile>? queue)
      : this._(status: FavoritesPlaylistStatus.success, playlists: queue);

  const FavoritesPlaylistState.failure(String error)
      : this._(status: FavoritesPlaylistStatus.failure, error: error);

  @override
  List<Object?> get props => [status, playlists, error];
}

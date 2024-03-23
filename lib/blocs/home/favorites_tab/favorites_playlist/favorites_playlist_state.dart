part of 'favorites_playlist_bloc.dart';

enum FavoritesPlaylistStatus { initial, loading, success, failure }

class FavoritesPlaylistState extends Equatable {
  const FavoritesPlaylistState._(
      {required this.status, this.resources, this.error});

  final FavoritesPlaylistStatus status;
  final List<ResourceMT>? resources;
  final String? error;

  const FavoritesPlaylistState.initial()
      : this._(status: FavoritesPlaylistStatus.initial);

  const FavoritesPlaylistState.loading()
      : this._(status: FavoritesPlaylistStatus.loading);

  const FavoritesPlaylistState.success(List<ResourceMT>? queue)
      : this._(status: FavoritesPlaylistStatus.success, resources: queue);

  const FavoritesPlaylistState.failure(String error)
      : this._(status: FavoritesPlaylistStatus.failure, error: error);

  @override
  List<Object?> get props => [status, resources, error];
}

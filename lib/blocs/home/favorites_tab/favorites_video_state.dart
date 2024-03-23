part of 'favorites_video_bloc.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesVideoState extends Equatable {
  const FavoritesVideoState._(
      {required this.status, this.resources, this.error});

  final FavoritesStatus status;
  final List<ResourceMT>? resources;
  final String? error;

  const FavoritesVideoState.initial() : this._(status: FavoritesStatus.initial);
  const FavoritesVideoState.loading() : this._(status: FavoritesStatus.loading);
  const FavoritesVideoState.success(List<ResourceMT>? queue)
      : this._(status: FavoritesStatus.success, resources: queue);
  const FavoritesVideoState.failure(String error)
      : this._(status: FavoritesStatus.failure, error: error);

  @override
  List<Object?> get props => [status, resources, error];
}

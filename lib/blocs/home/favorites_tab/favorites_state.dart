part of 'favorites_bloc.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  const FavoritesState._({required this.status, this.resources, this.error});

  final FavoritesStatus status;
  final List<ResourceMT>? resources;
  final String? error;

  const FavoritesState.initial() : this._(status: FavoritesStatus.initial);
  const FavoritesState.loading() : this._(status: FavoritesStatus.loading);
  const FavoritesState.success(List<ResourceMT>? queue)
      : this._(status: FavoritesStatus.success, resources: queue);
  const FavoritesState.failure(String error)
      : this._(status: FavoritesStatus.failure, error: error);

  @override
  List<Object?> get props => [status, resources, error];
}

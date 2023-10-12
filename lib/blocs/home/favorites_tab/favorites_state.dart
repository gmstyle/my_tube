part of 'favorites_bloc.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  const FavoritesState._({
    required this.status,
    this.error,
  });

  final FavoritesStatus status;
  final String? error;

  const FavoritesState.initial() : this._(status: FavoritesStatus.initial);

  @override
  List<Object> get props => [];
}

part of 'favorites_tab_bloc.dart';

enum FavoritesStatus { initial, loading, success, error }

class FavoritesTabState extends Equatable {
  const FavoritesTabState._({
    required this.status,
    this.error,
    this.response,
  });

  final FavoritesStatus status;
  final String? error;
  final VideoResponseMT? response;

  const FavoritesTabState.loading() : this._(status: FavoritesStatus.loading);
  const FavoritesTabState.loaded({required VideoResponseMT response})
      : this._(
          status: FavoritesStatus.success,
          response: response,
        );
  const FavoritesTabState.error({required String error})
      : this._(status: FavoritesStatus.error, error: error);

  @override
  List<Object?> get props => [status, error, response];
}

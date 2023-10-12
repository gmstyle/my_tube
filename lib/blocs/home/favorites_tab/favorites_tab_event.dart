part of 'favorites_tab_bloc.dart';

sealed class FavoritesTabEvent extends Equatable {
  const FavoritesTabEvent();

  @override
  List<Object> get props => [];
}

class GetFavorites extends FavoritesTabEvent {
  const GetFavorites();
}

class GetNextPageFavorites extends FavoritesTabEvent {
  const GetNextPageFavorites({required this.nextPageToken});

  final String nextPageToken;

  @override
  List<Object> get props => [nextPageToken];
}

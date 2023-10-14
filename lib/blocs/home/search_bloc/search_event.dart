part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchContents extends SearchEvent {
  const SearchContents({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

class GetNextPageSearchContents extends SearchEvent {
  const GetNextPageSearchContents(
      {required this.query, required this.nextPageToken});

  final String query;
  final String nextPageToken;

  @override
  List<Object> get props => [query, nextPageToken];
}

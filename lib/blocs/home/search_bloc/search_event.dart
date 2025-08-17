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

class LoadMoreSearchContents extends SearchEvent {
  const LoadMoreSearchContents();

  @override
  List<Object> get props => [];
}

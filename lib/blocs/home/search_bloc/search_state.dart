part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  const SearchState._({
    required this.status,
    this.items,
    this.searchList,
    this.isLoadingMore = false,
    this.error,
  });

  final SearchStatus status;
  final List<dynamic>? items; // current accumulated items
  final Object? searchList; // opaque holder for SearchList from library
  final bool isLoadingMore; // true when loading next page
  final String? error;

  const SearchState.initial() : this._(status: SearchStatus.initial);
  const SearchState.loading() : this._(status: SearchStatus.loading);
  const SearchState.success({List<dynamic>? items, Object? searchList})
      : this._(
            status: SearchStatus.success, items: items, searchList: searchList);
  const SearchState.failure(String error)
      : this._(status: SearchStatus.failure, error: error);

  // copyWith helper
  SearchState copyWith({
    SearchStatus? status,
    List<dynamic>? items,
    Object? searchList,
    bool? isLoadingMore,
    String? error,
  }) {
    return SearchState._(
      status: status ?? this.status,
      items: items ?? this.items,
      searchList: searchList ?? this.searchList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, items, searchList, isLoadingMore, error];
}

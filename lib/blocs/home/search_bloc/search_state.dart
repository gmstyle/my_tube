part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  const SearchState._({required this.status, this.result, this.error});

  final SearchStatus status;
  final List<VideoMT>? result;
  final String? error;

  const SearchState.initial() : this._(status: SearchStatus.initial);
  const SearchState.loading() : this._(status: SearchStatus.loading);
  const SearchState.success(List<VideoMT>? result)
      : this._(status: SearchStatus.success, result: result);
  const SearchState.failure(String error)
      : this._(status: SearchStatus.failure, error: error);

  @override
  List<Object?> get props => [status, result, error];
}

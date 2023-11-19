part of 'search_suggestion_cubit.dart';

class SearchSuggestionState extends Equatable {
  const SearchSuggestionState(
      {required this.suggestions, this.isQueryHistory = false});

  final List<String> suggestions;
  final bool isQueryHistory;

  @override
  List<Object> get props => [suggestions, isQueryHistory];
}

import 'package:equatable/equatable.dart';

class SuggestionResponseMT extends Equatable {
  final String query;
  final List<String> suggestions;

  const SuggestionResponseMT({
    required this.query,
    required this.suggestions,
  });

  factory SuggestionResponseMT.fromJson(Map<String, dynamic> json) =>
      SuggestionResponseMT(
        query: json['query'] as String,
        suggestions: (json['suggestions'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'query': query,
        'suggestions': suggestions,
      };

  @override
  List<Object?> get props => [query, suggestions];
}

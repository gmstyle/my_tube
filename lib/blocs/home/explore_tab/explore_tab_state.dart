part of 'explore_tab_bloc.dart';

enum YoutubeStatus { initial, loading, loaded, error }

class ExploreTabState extends Equatable {
  const ExploreTabState._({required this.status, this.error, this.response});

  final YoutubeStatus status;
  final String? error;
  final ResponseMT? response;

  const ExploreTabState.loading() : this._(status: YoutubeStatus.loading);
  const ExploreTabState.loaded({required ResponseMT response})
      : this._(
          status: YoutubeStatus.loaded,
          response: response,
        );
  const ExploreTabState.error({required String error})
      : this._(status: YoutubeStatus.error, error: error);

  @override
  List<Object?> get props => [status, error, response];
}

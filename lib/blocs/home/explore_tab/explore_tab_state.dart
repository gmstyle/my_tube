part of 'explore_tab_bloc.dart';

enum YoutubeStatus { initial, loading, loaded, error }

class ExploreTabState extends Equatable {
  const ExploreTabState._({required this.status, this.error, this.videos});

  final YoutubeStatus status;
  final String? error;
  final List<VideoTile>? videos;

  const ExploreTabState.loading() : this._(status: YoutubeStatus.loading);
  const ExploreTabState.loaded({required List<VideoTile> response})
      : this._(
          status: YoutubeStatus.loaded,
          videos: response,
        );
  const ExploreTabState.error({required String error})
      : this._(status: YoutubeStatus.error, error: error);

  @override
  List<Object?> get props => [status, error, videos];
}

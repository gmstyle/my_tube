part of 'explore_tab_bloc.dart';

enum YoutubeStatus { initial, loading, loaded, error }

class ExploreTabState extends Equatable {
  const ExploreTabState._(
      {required this.status, this.error, this.videos, this.nextPageToken});

  final YoutubeStatus status;
  final String? error;
  final List<VideoMT>? videos;
  final String? nextPageToken;

  const ExploreTabState.loading() : this._(status: YoutubeStatus.loading);
  const ExploreTabState.loaded(
      {required List<VideoMT> videos, String? nextPageToken})
      : this._(
            status: YoutubeStatus.loaded,
            videos: videos,
            nextPageToken: nextPageToken);
  const ExploreTabState.error({required String error})
      : this._(status: YoutubeStatus.error, error: error);

  @override
  List<Object?> get props => [status, error, videos];
}

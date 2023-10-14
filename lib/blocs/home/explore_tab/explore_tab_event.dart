part of 'explore_tab_bloc.dart';

sealed class ExploreTabEvent extends Equatable {
  const ExploreTabEvent();
}

class GetTrendingVideos extends ExploreTabEvent {
  const GetTrendingVideos();

  @override
  List<Object?> get props => [];
}

class GetNextPageTrendingVideos extends ExploreTabEvent {
  const GetNextPageTrendingVideos({required this.nextPageToken});

  final String nextPageToken;

  @override
  List<Object> get props => [nextPageToken];
}

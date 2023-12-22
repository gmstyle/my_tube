part of 'explore_tab_bloc.dart';

sealed class ExploreTabEvent extends Equatable {
  const ExploreTabEvent();
}

class GetTrendingVideos extends ExploreTabEvent {
  final String category;
  const GetTrendingVideos({required this.category});

  @override
  List<Object?> get props => [category];
}

class GetNextPageTrendingVideos extends ExploreTabEvent {
  const GetNextPageTrendingVideos({required this.nextPageToken});

  final String nextPageToken;

  @override
  List<Object> get props => [nextPageToken];
}

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
  const GetNextPageTrendingVideos({this.nextPageToken});

  final String? nextPageToken;
  final bool isLoadingNextPage = true;

  @override
  List<Object?> get props => [nextPageToken, isLoadingNextPage];
}

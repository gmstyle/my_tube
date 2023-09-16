part of 'explore_tab_bloc.dart';

sealed class ExploreTabEvent extends Equatable {
  const ExploreTabEvent();
}

class GetVideos extends ExploreTabEvent {
  const GetVideos();

  @override
  List<Object?> get props => [];
}

class GetNextPageVideos extends ExploreTabEvent {
  const GetNextPageVideos({this.nextPageToken});

  final String? nextPageToken;
  final bool isLoadingNextPage = true;

  @override
  List<Object?> get props => [nextPageToken, isLoadingNextPage];
}

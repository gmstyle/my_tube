part of 'explore_tab_bloc.dart';

sealed class ExploreTabEvent extends Equatable {
  const ExploreTabEvent();
}

class GetTrendingVideos extends ExploreTabEvent {
  final CategoryEnum category;
  const GetTrendingVideos({required this.category});

  @override
  List<Object?> get props => [category];
}

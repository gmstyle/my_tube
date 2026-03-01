part of 'explore_tab_bloc.dart';

enum CategoryEnum { now, music, film, gaming }

sealed class ExploreTabEvent extends Equatable {
  const ExploreTabEvent();
}

class GetTrendingVideos extends ExploreTabEvent {
  final CategoryEnum category;
  const GetTrendingVideos({required this.category});

  @override
  List<Object?> get props => [category];
}

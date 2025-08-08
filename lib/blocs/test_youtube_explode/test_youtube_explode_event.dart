part of 'test_youtube_explode_bloc.dart';

abstract class TestYoutubeExplodeEvent extends Equatable {
  const TestYoutubeExplodeEvent();

  @override
  List<Object?> get props => [];
}

class TestGetVideo extends TestYoutubeExplodeEvent {
  final String videoId;

  const TestGetVideo(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class TestSearchVideos extends TestYoutubeExplodeEvent {
  final String query;

  const TestSearchVideos(this.query);

  @override
  List<Object?> get props => [query];
}

class TestGetTrending extends TestYoutubeExplodeEvent {
  const TestGetTrending();
}

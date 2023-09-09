part of 'home_bloc.dart';

enum YoutubeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  const HomeState._({required this.status, this.error, this.videos});

  final YoutubeStatus status;
  final String? error;
  final List<Video>? videos;

  const HomeState.initial() : this._(status: YoutubeStatus.initial);
  const HomeState.loading() : this._(status: YoutubeStatus.loading);
  const HomeState.loaded({required List<Video> videos})
      : this._(status: YoutubeStatus.loaded, videos: videos);
  const HomeState.error({required String error})
      : this._(status: YoutubeStatus.error, error: error);

  @override
  List<Object> get props => [];
}

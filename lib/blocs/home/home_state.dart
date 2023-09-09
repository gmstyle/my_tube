part of 'home_bloc.dart';

enum YoutubeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  const HomeState._(
      {required this.status, required this.error, required this.videos});

  final YoutubeStatus status;
  final String? error;
  final List<Video> videos;

  const HomeState.initial()
      : this._(status: YoutubeStatus.initial, error: null, videos: const []);
  const HomeState.loading()
      : this._(status: YoutubeStatus.loading, error: null, videos: const []);
  const HomeState.loaded(List<Video> videos)
      : this._(status: YoutubeStatus.loaded, error: null, videos: videos);
  const HomeState.error(String error)
      : this._(status: YoutubeStatus.error, error: error, videos: const []);

  @override
  List<Object> get props => [];
}

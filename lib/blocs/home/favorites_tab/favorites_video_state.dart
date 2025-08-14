part of 'favorites_video_bloc.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesVideoState extends Equatable {
  const FavoritesVideoState._({required this.status, this.videos, this.error});

  final FavoritesStatus status;
  final List<VideoTile>? videos;
  final String? error;

  const FavoritesVideoState.initial() : this._(status: FavoritesStatus.initial);
  const FavoritesVideoState.loading() : this._(status: FavoritesStatus.loading);
  const FavoritesVideoState.success(List<VideoTile>? videos)
      : this._(status: FavoritesStatus.success, videos: videos);
  const FavoritesVideoState.failure(String error)
      : this._(status: FavoritesStatus.failure, error: error);

  @override
  List<Object?> get props => [status, videos, error];
}

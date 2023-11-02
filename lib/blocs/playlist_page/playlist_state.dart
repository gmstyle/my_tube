part of 'playlist_bloc.dart';

enum PlaylistStatus { initial, loading, loaded, failure }

class PlaylistState extends Equatable {
  const PlaylistState._({
    required this.status,
    this.response,
    this.videoIds,
    this.error,
  });

  final PlaylistStatus status;
  final PlaylistResponseMT? response;
  final List<String>? videoIds;
  final String? error;

  const PlaylistState.initial() : this._(status: PlaylistStatus.initial);
  const PlaylistState.loading() : this._(status: PlaylistStatus.loading);
  const PlaylistState.success(
      PlaylistResponseMT response, List<String> videoIds)
      : this._(
          status: PlaylistStatus.loaded,
          response: response,
          videoIds: videoIds,
        );
  const PlaylistState.failure(String error)
      : this._(status: PlaylistStatus.failure, error: error);

  @override
  List<Object?> get props => [status, response, error];
}

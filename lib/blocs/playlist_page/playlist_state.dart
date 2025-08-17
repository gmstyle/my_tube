part of 'playlist_bloc.dart';

enum PlaylistStatus { initial, loading, loaded, failure }

class PlaylistState extends Equatable {
  const PlaylistState._({
    required this.status,
    this.response,
    this.error,
  });

  final PlaylistStatus status;
  final Map<String, dynamic>? response;
  final String? error;

  const PlaylistState.initial() : this._(status: PlaylistStatus.initial);
  const PlaylistState.loading() : this._(status: PlaylistStatus.loading);
  const PlaylistState.success(Map<String, dynamic> response)
      : this._(
          status: PlaylistStatus.loaded,
          response: response,
        );
  const PlaylistState.failure(String error)
      : this._(status: PlaylistStatus.failure, error: error);

  @override
  List<Object?> get props => [status, response, error];
}

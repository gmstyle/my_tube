part of 'playlist_bloc.dart';

sealed class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

class GetPlaylist extends PlaylistEvent {
  final String playlistId;

  const GetPlaylist({required this.playlistId});

  @override
  List<Object?> get props => [playlistId];
}

class GetNextPagePlaylist extends PlaylistEvent {
  final String playlistId;
  final String nextPageToken;

  const GetNextPagePlaylist(
      {required this.playlistId, required this.nextPageToken});

  @override
  List<Object?> get props => [playlistId, nextPageToken];
}

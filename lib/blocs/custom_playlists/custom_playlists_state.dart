import 'package:equatable/equatable.dart';
import 'package:my_tube/models/custom_playlist.dart';

enum CustomPlaylistsStatus { initial, loading, success, failure }

class CustomPlaylistsState extends Equatable {
  final CustomPlaylistsStatus status;
  final List<CustomPlaylist> playlists;
  final String? errorMessage;

  const CustomPlaylistsState({
    this.status = CustomPlaylistsStatus.initial,
    this.playlists = const [],
    this.errorMessage,
  });

  CustomPlaylistsState copyWith({
    CustomPlaylistsStatus? status,
    List<CustomPlaylist>? playlists,
    String? errorMessage,
  }) {
    return CustomPlaylistsState(
      status: status ?? this.status,
      playlists: playlists ?? this.playlists,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, playlists, errorMessage];
}

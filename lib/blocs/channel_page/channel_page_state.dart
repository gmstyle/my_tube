part of 'channel_page_bloc.dart';

enum ChannelPageStatus { initial, loading, loaded, failure }

class ChannelPageState extends Equatable {
  const ChannelPageState._({
    required this.status,
    this.data,
    this.items,
    this.uploadsList,
    this.isLoadingMore = false,
    // Shorts tab
    this.shorts,
    this.shortsList,
    this.isLoadingShorts = false,
    this.isLoadingMoreShorts = false,
    // Playlists tab
    this.playlists,
    this.playlistsList,
    this.isLoadingPlaylists = false,
    this.isLoadingMorePlaylists = false,
    this.error,
  });

  final ChannelPageStatus status;
  final Map<String, dynamic>? data; // original channel metadata
  final List<dynamic>? items; // accumulated video tiles
  final Object? uploadsList; // opaque ChannelUploadsList
  final bool isLoadingMore;

  // Shorts tab
  final List<dynamic>? shorts; // accumulated VideoTile shorts
  final Object? shortsList; // opaque ChannelUploadsList for shorts
  final bool isLoadingShorts;
  final bool isLoadingMoreShorts;

  // Playlists tab
  final List<dynamic>? playlists; // accumulated PlaylistTile
  final Object? playlistsList; // opaque SearchList
  final bool isLoadingPlaylists;
  final bool isLoadingMorePlaylists;

  final String? error;

  const ChannelPageState.initial() : this._(status: ChannelPageStatus.initial);
  const ChannelPageState.loading() : this._(status: ChannelPageStatus.loading);
  const ChannelPageState.loaded(Map<String, dynamic> data,
      {List<dynamic>? items, Object? uploadsList})
      : this._(
            status: ChannelPageStatus.loaded,
            data: data,
            items: items,
            uploadsList: uploadsList);
  const ChannelPageState.failure({required String error})
      : this._(status: ChannelPageStatus.failure, error: error);

  ChannelPageState copyWith({
    ChannelPageStatus? status,
    Map<String, dynamic>? data,
    List<dynamic>? items,
    Object? uploadsList,
    bool? isLoadingMore,
    List<dynamic>? shorts,
    Object? shortsList,
    bool? isLoadingShorts,
    bool? isLoadingMoreShorts,
    List<dynamic>? playlists,
    Object? playlistsList,
    bool? isLoadingPlaylists,
    bool? isLoadingMorePlaylists,
    String? error,
  }) {
    return ChannelPageState._(
      status: status ?? this.status,
      data: data ?? this.data,
      items: items ?? this.items,
      uploadsList: uploadsList ?? this.uploadsList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      shorts: shorts ?? this.shorts,
      shortsList: shortsList ?? this.shortsList,
      isLoadingShorts: isLoadingShorts ?? this.isLoadingShorts,
      isLoadingMoreShorts: isLoadingMoreShorts ?? this.isLoadingMoreShorts,
      playlists: playlists ?? this.playlists,
      playlistsList: playlistsList ?? this.playlistsList,
      isLoadingPlaylists: isLoadingPlaylists ?? this.isLoadingPlaylists,
      isLoadingMorePlaylists:
          isLoadingMorePlaylists ?? this.isLoadingMorePlaylists,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        data,
        items,
        uploadsList,
        isLoadingMore,
        shorts,
        shortsList,
        isLoadingShorts,
        isLoadingMoreShorts,
        playlists,
        playlistsList,
        isLoadingPlaylists,
        isLoadingMorePlaylists,
        error,
      ];
}

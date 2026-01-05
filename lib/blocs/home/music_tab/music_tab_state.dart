part of 'music_tab_bloc.dart';

enum MusicTabStatus { initial, loading, success, error }

class MusicTabState extends Equatable {
  const MusicTabState._({
    required this.status,
    this.error,
    this.newReleases = const [],
    this.discoverVideo,
    this.discoverRelated = const [],
    this.trending = const [],
    this.isInternationalTrending = false,
  });

  final MusicTabStatus status;
  final String? error;
  final List<VideoTile> newReleases;
  final VideoTile? discoverVideo;
  final List<VideoTile> discoverRelated;
  final List<VideoTile> trending;
  final bool isInternationalTrending;

  const MusicTabState.initial() : this._(status: MusicTabStatus.initial);

  const MusicTabState.loading() : this._(status: MusicTabStatus.loading);

  const MusicTabState.loaded({
    List<VideoTile> newReleases = const [],
    VideoTile? discoverVideo,
    List<VideoTile> discoverRelated = const [],
    List<VideoTile> trending = const [],
    bool isInternationalTrending = false,
  }) : this._(
          status: MusicTabStatus.success,
          newReleases: newReleases,
          discoverVideo: discoverVideo,
          discoverRelated: discoverRelated,
          trending: trending,
          isInternationalTrending: isInternationalTrending,
        );

  const MusicTabState.error({required String error})
      : this._(status: MusicTabStatus.error, error: error);

  @override
  List<Object?> get props => [
        status,
        error,
        newReleases,
        discoverVideo,
        discoverRelated,
        trending,
        isInternationalTrending
      ];
}

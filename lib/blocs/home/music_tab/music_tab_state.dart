part of 'music_tab_bloc.dart';

enum MusicTabStatus { initial, loading, success, error }

class MusicTabState extends Equatable {
  const MusicTabState._({
    required this.status,
    this.error,
    this.featuredChannels = const [],
    this.recentlyPlayed = const [],
    this.newReleases = const [],
    this.discoverVideo,
    this.discoverRelated = const [],
    this.trending = const [],
    this.isInternationalTrending = false,
    this.isFeaturedChannelsLoading = false,
    this.isNewReleasesLoading = false,
    this.isDiscoverLoading = false,
    this.isTrendingLoading = false,
  });

  final MusicTabStatus status;
  final String? error;
  final List<ChannelTile> featuredChannels;
  final List<VideoTile> recentlyPlayed;
  final List<VideoTile> newReleases;
  final VideoTile? discoverVideo;
  final List<VideoTile> discoverRelated;
  final List<VideoTile> trending;
  final bool isInternationalTrending;

  /// True while the Featured Channels network call is in progress.
  final bool isFeaturedChannelsLoading;

  /// True while the New Releases network call is in progress.
  final bool isNewReleasesLoading;

  /// True while the Discover network call is in progress.
  final bool isDiscoverLoading;

  /// True while the Trending network call is in progress.
  final bool isTrendingLoading;

  const MusicTabState.initial() : this._(status: MusicTabStatus.initial);

  const MusicTabState.loading() : this._(status: MusicTabStatus.loading);

  const MusicTabState.loaded({
    List<ChannelTile> featuredChannels = const [],
    List<VideoTile> recentlyPlayed = const [],
    List<VideoTile> newReleases = const [],
    VideoTile? discoverVideo,
    List<VideoTile> discoverRelated = const [],
    List<VideoTile> trending = const [],
    bool isInternationalTrending = false,
    bool isFeaturedChannelsLoading = false,
    bool isNewReleasesLoading = false,
    bool isDiscoverLoading = false,
    bool isTrendingLoading = false,
  }) : this._(
          status: MusicTabStatus.success,
          featuredChannels: featuredChannels,
          recentlyPlayed: recentlyPlayed,
          newReleases: newReleases,
          discoverVideo: discoverVideo,
          discoverRelated: discoverRelated,
          trending: trending,
          isInternationalTrending: isInternationalTrending,
          isFeaturedChannelsLoading: isFeaturedChannelsLoading,
          isNewReleasesLoading: isNewReleasesLoading,
          isDiscoverLoading: isDiscoverLoading,
          isTrendingLoading: isTrendingLoading,
        );

  const MusicTabState.error({required String error})
      : this._(status: MusicTabStatus.error, error: error);

  MusicTabState copyWith({
    MusicTabStatus? status,
    String? error,
    List<ChannelTile>? featuredChannels,
    List<VideoTile>? recentlyPlayed,
    List<VideoTile>? newReleases,
    VideoTile? discoverVideo,
    List<VideoTile>? discoverRelated,
    List<VideoTile>? trending,
    bool? isInternationalTrending,
    bool? isFeaturedChannelsLoading,
    bool? isNewReleasesLoading,
    bool? isDiscoverLoading,
    bool? isTrendingLoading,
  }) {
    return MusicTabState._(
      status: status ?? this.status,
      error: error ?? this.error,
      featuredChannels: featuredChannels ?? this.featuredChannels,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      newReleases: newReleases ?? this.newReleases,
      discoverVideo: discoverVideo ?? this.discoverVideo,
      discoverRelated: discoverRelated ?? this.discoverRelated,
      trending: trending ?? this.trending,
      isInternationalTrending:
          isInternationalTrending ?? this.isInternationalTrending,
      isFeaturedChannelsLoading:
          isFeaturedChannelsLoading ?? this.isFeaturedChannelsLoading,
      isNewReleasesLoading: isNewReleasesLoading ?? this.isNewReleasesLoading,
      isDiscoverLoading: isDiscoverLoading ?? this.isDiscoverLoading,
      isTrendingLoading: isTrendingLoading ?? this.isTrendingLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        featuredChannels,
        recentlyPlayed,
        newReleases,
        discoverVideo,
        discoverRelated,
        trending,
        isInternationalTrending,
        isFeaturedChannelsLoading,
        isNewReleasesLoading,
        isDiscoverLoading,
        isTrendingLoading,
      ];
}

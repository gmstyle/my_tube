import 'package:innertube_dart/enums/enums.dart';
import 'package:my_tube/models/channel_mt.dart';
import 'package:my_tube/models/channel_page_mt.dart';
import 'package:my_tube/models/music_home_mt.dart';
import 'package:my_tube/models/playlist_mt.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/providers/innertube_provider.dart';

class InnertubeRepository {
  InnertubeRepository({required this.innertubeProvider});

  final InnertubeProvider innertubeProvider;

  Future<ResourceMT> getVideo(String videoId, {bool? withStreamUrl}) async {
    final video = await innertubeProvider.getVideo(videoId, withStreamUrl);
    return ResourceMT(
      id: video.videoId,
      title: video.title,
      description: video.description,
      channelTitle: video.author,
      thumbnailUrl: video.thumbnails?.last.url,
      kind: 'video',
      channelId: video.channelId,
      playlistId: '',
      streamUrl: video.muxedStreamingUrl,
      duration: video.durationMs != null ? int.parse(video.durationMs!) : null,
    );
  }

  Future<ResponseMT> getTrending(TrendingCategory trendingCategory) async {
    final response = await innertubeProvider.getTrending(trendingCategory);
    if (response.videos != null) {
      final resources = response.videos!
          .map((video) => ResourceMT(
                id: video.videoId,
                title: video.title,
                description: video.description,
                channelTitle: video.author,
                thumbnailUrl: video.thumbnails?.first.url,
                kind: 'video',
                channelId: video.channelId,
                playlistId: '',
                streamUrl: video.muxedStreamingUrl,
                duration: video.durationMs != null
                    ? int.parse(video.durationMs!)
                    : null,
              ))
          .toList();
      return ResponseMT(resources: resources, nextPageToken: null);
    } else {
      return const ResponseMT(resources: [], nextPageToken: null);
    }
  }

  Future<MusicHomeMT> getMusicHome() async {
    final response = await innertubeProvider.getMusicHome();
    final carouselVideos = response.carouselVideos
        ?.map((video) => ResourceMT(
              id: video.videoId,
              title: video.title,
              description: video.description,
              channelTitle: video.author,
              thumbnailUrl: video.thumbnails?.last.url,
              kind: 'video',
              channelId: video.channelId,
              playlistId: null,
              streamUrl: video.muxedStreamingUrl,
              duration: video.durationMs != null
                  ? int.parse(video.durationMs!)
                  : null,
            ))
        .toList();
    final sections = response.sections!
        .map((section) => SectionMT(
              title: section.title,
              playlistId: section.playlistId,
              videos: section.videos
                  ?.map((video) => ResourceMT(
                        id: video.videoId,
                        title: video.title,
                        description: video.description,
                        channelTitle: video.author,
                        thumbnailUrl: video.thumbnails?.last.url,
                        kind: null,
                        channelId: video.channelId,
                        playlistId: null,
                        streamUrl: video.muxedStreamingUrl,
                        duration: video.durationMs != null
                            ? int.parse(video.durationMs!)
                            : null,
                      ))
                  .toList(),
              playlists: section.playlists
                  ?.map((playlist) => PlaylistMT(
                      id: playlist.playlistId,
                      channelId: null,
                      title: playlist.title,
                      description: playlist.description,
                      thumbnailUrl: playlist.thumbnails?.last.url,
                      itemCount: int.tryParse(playlist.videoCount ?? '0'),
                      videos: playlist.videos
                          ?.map((video) => ResourceMT(
                                id: video.videoId,
                                title: video.title,
                                description: video.description,
                                channelTitle: video.author,
                                thumbnailUrl: video.thumbnails?.last.url,
                                kind: 'playlist',
                                channelId: video.channelId,
                                playlistId: '',
                                streamUrl: video.muxedStreamingUrl,
                                duration: video.durationMs != null
                                    ? int.parse(video.durationMs!)
                                    : null,
                              ))
                          .toList()))
                  .toList(),
            ))
        .toList();
    return MusicHomeMT(
      title: response.title,
      description: response.description,
      carouselVideos: carouselVideos,
      sections: sections,
    );
  }

  Future<PlaylistMT> getPlaylist(String playlistId) async {
    final playlist = await innertubeProvider.getPlaylist(playlistId);
    final resources = playlist.videos!
        .map((video) => ResourceMT(
              id: video.videoId,
              title: video.title,
              description: video.description,
              channelTitle: video.author,
              thumbnailUrl: video.thumbnails?.first.url,
              kind: 'video',
              channelId: video.channelId,
              playlistId: playlist.playlistId,
              streamUrl: video.muxedStreamingUrl,
              duration: video.durationMs != null
                  ? int.parse(video.durationMs!)
                  : null,
            ))
        .toList();
    return PlaylistMT(
        id: playlist.playlistId,
        channelId: null,
        title: playlist.title,
        description: playlist.description,
        thumbnailUrl: playlist.thumbnails?.last.url,
        itemCount: resources.length,
        videos: resources);
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    final suggestions = await innertubeProvider.getSearchSuggestions(query);
    return suggestions ?? [];
  }

  Future<ResponseMT> searchContents(
      {required String query, String? nextPageToken}) async {
    final response = await innertubeProvider.searchContents(
        query: query, nextPageToken: nextPageToken);
    final resources = <ResourceMT>[];
    if (response.videos != null) {
      final videos = response.videos!
          .map((video) => ResourceMT(
                id: video.videoId,
                title: video.title,
                description: video.description,
                channelTitle: video.author,
                thumbnailUrl: video.thumbnails?.last.url,
                kind: 'video',
                channelId: video.channelId,
                playlistId: null,
                streamUrl: video.muxedStreamingUrl,
                duration: video.durationMs != null
                    ? int.parse(video.durationMs!)
                    : null,
              ))
          .toList();
      resources.addAll(videos);
    }

    if (response.channels != null) {
      final channels = response.channels!
          .map((channel) => ResourceMT(
                id: channel.channelId,
                title: channel.title,
                description: channel.description,
                channelTitle: channel.title,
                thumbnailUrl: channel.thumbnails?.last.url,
                kind: 'channel',
                channelId: channel.channelId,
                playlistId: null,
                streamUrl: null,
                duration: null,
                subscriberCount: channel.subscriberCount,
                videoCount: channel.videoCount,
              ))
          .toList();
      resources.addAll(channels);
    }

    if (response.playlists != null) {
      final playlists = response.playlists!
          .map((playlist) => ResourceMT(
                id: playlist.playlistId,
                title: playlist.title,
                description: playlist.description,
                channelTitle: null,
                thumbnailUrl: playlist.thumbnails?.last.url,
                kind: 'playlist',
                channelId: null,
                playlistId: playlist.playlistId,
                streamUrl: null,
                duration: null,
              ))
          .toList();
      resources.addAll(playlists);
    }

    return ResponseMT(
        resources: resources, nextPageToken: response.continuationToken);
  }

  Future<ChannelPageMT> getChannel(String channelId) async {
    final channel = await innertubeProvider.getChannel(channelId);
    final sections = channel.sections
        ?.map((section) => SectionMT(
              title: section.title,
              playlistId: section.playlistId,
              videos: section.videos
                  ?.map((video) => ResourceMT(
                        id: video.videoId,
                        title: video.title,
                        description: video.description,
                        channelTitle: video.author,
                        thumbnailUrl: video.thumbnails?.last.url,
                        kind: 'video',
                        channelId: video.channelId,
                        playlistId: '',
                        streamUrl: video.muxedStreamingUrl,
                        duration: video.durationMs != null
                            ? int.parse(video.durationMs!)
                            : null,
                      ))
                  .toList(),
              playlists: section.playlists
                  ?.map((playlist) => PlaylistMT(
                      id: playlist.playlistId,
                      channelId: null,
                      title: playlist.title,
                      description: playlist.description,
                      thumbnailUrl: playlist.thumbnails?.last.url,
                      itemCount: int.tryParse(playlist.videoCount ?? '0'),
                      videos: playlist.videos
                          ?.map((video) => ResourceMT(
                                id: video.videoId,
                                title: video.title,
                                description: video.description,
                                channelTitle: video.author,
                                thumbnailUrl: video.thumbnails?.last.url,
                                kind: 'playlist',
                                channelId: video.channelId,
                                playlistId: '',
                                streamUrl: video.muxedStreamingUrl,
                                duration: video.durationMs != null
                                    ? int.parse(video.durationMs!)
                                    : null,
                              ))
                          .toList()))
                  .toList(),
              channel: section.featuredChannel != null
                  ? ResourceMT(
                      id: section.featuredChannel!.channelId,
                      title: section.featuredChannel!.title,
                      description: section.featuredChannel!.description,
                      channelTitle: section.featuredChannel!.title,
                      thumbnailUrl:
                          section.featuredChannel!.thumbnails?.last.url,
                      kind: 'channel',
                      channelId: section.featuredChannel!.channelId,
                      subscriberCount: channel.subscriberCount,
                      videoCount: channel.videoCount,
                      playlistId: null,
                      streamUrl: null,
                      duration: null,
                    )
                  : null,
            ))
        .toList();

    return ChannelPageMT(
      title: channel.title,
      description: channel.description,
      channelHandleText: channel.channelHandleText,
      avatarUrl: channel.avatars?.last.url,
      bannerUrl: channel.banners?.last.url,
      thumbnailUrl: channel.thumbnails?.last.url,
      tvBannerUrl: channel.tvBanners?.last.url,
      sections: sections,
      subscriberCount: channel.subscriberCount,
    );
  }
}

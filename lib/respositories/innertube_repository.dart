import 'dart:developer';

import 'package:innertube_dart/enums/enums.dart';
import 'package:innertube_dart/models/responses/playlist.dart';
import 'package:innertube_dart/models/responses/video.dart';
import 'package:innertube_dart/models/responses/channel.dart';

import 'package:my_tube/models/channel_page_mt.dart';
import 'package:my_tube/models/music_home_mt.dart';
import 'package:my_tube/models/playlist_mt.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/providers/innertube_provider.dart';
import 'package:my_tube/utils/enums.dart';

class InnertubeRepository {
  InnertubeRepository({required this.innertubeProvider});

  final InnertubeProvider innertubeProvider;

  Future<String?> _getBase64Thumbnail(String? url) async {
    return url != null ? await innertubeProvider.getBase64Image(url) : null;
  }

  Future<ResourceMT> getResourceMTFromVideo(Video video) async {
    return ResourceMT(
      id: video.videoId,
      title: video.title,
      description: video.description,
      channelTitle: video.author,
      thumbnailUrl: video.thumbnails?.last.url,
      kind: Kind.video.name,
      channelId: video.channelId,
      playlistId: '',
      streamUrl: video.muxedStreamingUrl,
      duration: video.durationMs != null ? int.parse(video.durationMs!) : null,
      base64Thumbnail: await _getBase64Thumbnail(video.thumbnails?.last.url),
    );
  }

  Future<ResourceMT> getResourceMTFromPlaylist(Playlist playlist) async {
    return ResourceMT(
      id: playlist.playlistId,
      title: playlist.title,
      description: playlist.description,
      channelTitle: playlist.author,
      thumbnailUrl: playlist.thumbnails?.last.url,
      kind: Kind.playlist.name,
      channelId: null,
      playlistId: playlist.playlistId,
      streamUrl: null,
      duration: null,
      videoCount: playlist.videoCount,
      base64Thumbnail: await _getBase64Thumbnail(playlist.thumbnails?.last.url),
    );
  }

  Future<ResourceMT> getResourceMTFromChannel(Channel channel) async {
    return ResourceMT(
      id: channel.channelId,
      title: channel.title,
      description: channel.description,
      channelTitle: channel.title,
      thumbnailUrl: channel.thumbnails?.last.url,
      kind: Kind.channel.name,
      channelId: channel.channelId,
      playlistId: null,
      streamUrl: null,
      duration: null,
      subscriberCount: channel.subscriberCount,
      videoCount: channel.videoCount,
      base64Thumbnail: await _getBase64Thumbnail(channel.thumbnails?.last.url),
    );
  }

  Future<PlaylistMT> _getPlaylistMTFromPlaylist(Playlist playlist) async {
    final videos = playlist.videos!
        .map((video) async => await getResourceMTFromVideo(video))
        .toList();

    final base64thumbnail =
        await _getBase64Thumbnail(playlist.thumbnails?.last.url);
    return PlaylistMT(
      id: playlist.playlistId,
      channelId: null,
      title: playlist.title,
      description: playlist.description,
      thumbnailUrl: playlist.thumbnails?.last.url,
      base64Thumbnail: base64thumbnail,
      itemCount: playlist.videoCount,
      videos: await Future.wait(videos),
    );
  }

  Future<ResourceMT> getVideo(String videoId, {bool? withStreamUrl}) async {
    try {
      final video = await innertubeProvider.getVideo(videoId, withStreamUrl);
      return await getResourceMTFromVideo(video);
    } catch (e) {
      // Handle error
      log('Errore durante il recupero del video: $e');
      rethrow;
    }
  }

  Future<ResponseMT> getTrending(TrendingCategory trendingCategory) async {
    try {
      final response = await innertubeProvider.getTrending(trendingCategory);
      if (response.videos != null) {
        final resources = response.videos!
            .map((video) async => await getResourceMTFromVideo(video))
            .toList();
        final videoResources = await Future.wait(resources);
        return ResponseMT(resources: videoResources, nextPageToken: null);
      } else {
        return const ResponseMT(resources: [], nextPageToken: null);
      }
    } catch (e) {
      log('Errore durante il recupero dei trending video: $e');
      // Handle error
      rethrow;
    }
  }

  Future<MusicHomeMT> getMusicHome() async {
    try {
      final response = await innertubeProvider.getMusicHome();
      final carouselVideos = response.carouselVideos
          ?.map((video) async => await getResourceMTFromVideo(video))
          .toList();
      final sections =
          await Future.wait(response.sections!.map((section) async {
        final videos = await Future.wait<ResourceMT>(section.videos
                ?.map((video) async => await getResourceMTFromVideo(video))
                .toList() ??
            []);
        final playlists = await Future.wait<PlaylistMT>(section.playlists
                ?.map((playlist) async =>
                    await _getPlaylistMTFromPlaylist(playlist))
                .toList() ??
            []);
        return SectionMT(
          title: section.title,
          playlistId: section.playlistId,
          videos: videos,
          playlists: playlists,
        );
      }).toList());

      final carouselResources =
          carouselVideos != null ? await Future.wait(carouselVideos) : null;
      return MusicHomeMT(
        title: response.title,
        description: response.description,
        carouselVideos: carouselResources,
        sections: sections,
      );
    } catch (e) {
      // Handle error
      log('Errore durante il recupero della home music: $e');
      rethrow;
    }
  }

  Future<PlaylistMT> getPlaylist(String playlistId,
      {bool getVideos = true}) async {
    try {
      final playlist =
          await innertubeProvider.getPlaylist(playlistId, getVideos: getVideos);
      return await _getPlaylistMTFromPlaylist(playlist);
    } catch (e) {
      // Handle error
      log('Errore durante il recupero della playlist: $e');
      rethrow;
    }
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final suggestions = await innertubeProvider.getSearchSuggestions(query);
      return suggestions ?? [];
    } catch (e) {
      // Handle error
      log('Errore durante il recupero delle suggerimenti di ricerca: $e');
      rethrow;
    }
  }

  Future<ResponseMT> searchContents(
      {required String query, String? nextPageToken}) async {
    try {
      final response = await innertubeProvider.searchContents(
          query: query, nextPageToken: nextPageToken);
      final resources = <ResourceMT>[];
      if (response.videos != null) {
        final videos = response.videos!
            .map((video) async => await getResourceMTFromVideo(video))
            .toList();
        final videoResources = await Future.wait(videos);
        resources.addAll(videoResources);
      }

      if (response.channels != null) {
        final channels = response.channels!
            .map((channel) async => await getResourceMTFromChannel(channel))
            .toList();
        final channelResources = await Future.wait(channels);
        resources.addAll(channelResources);
      }

      if (response.playlists != null) {
        final playlists = response.playlists!
            .map((playlist) async => await getResourceMTFromPlaylist(playlist))
            .toList();
        final playlistResources = await Future.wait(playlists);
        resources.addAll(playlistResources);
      }

      return ResponseMT(
          resources: resources, nextPageToken: response.continuationToken);
    } catch (e) {
      // Handle error
      log('Errore durante la ricerca dei contenuti: $e');
      rethrow;
    }
  }

  Future<ChannelPageMT> getChannel(String channelId) async {
    try {
      final channel = await innertubeProvider.getChannel(channelId);
      final sections =
          await Future.wait<SectionMT>(channel.sections?.map((section) async {
                final videos = section.videos != null
                    ? await Future.wait<ResourceMT>(section.videos!
                        .map((video) async => await getResourceMTFromVideo(
                              video,
                            )))
                    : <ResourceMT>[];
                final playlists = section.playlists != null
                    ? await Future.wait<PlaylistMT>(section.playlists!.map(
                        (playlist) async =>
                            await _getPlaylistMTFromPlaylist(playlist)))
                    : <PlaylistMT>[];
                final channels = section.featuredChannels != null
                    ? await Future.wait<ResourceMT>(section.featuredChannels!
                        .map((channel) async =>
                            await getResourceMTFromChannel(channel)))
                    : <ResourceMT>[];
                return SectionMT(
                  title: section.title,
                  playlistId: section.playlistId,
                  videos: videos,
                  playlists: playlists,
                  channels: channels,
                );
              }).toList() ??
              []);

      return ChannelPageMT(
        title: channel.title,
        description: channel.description,
        channelHandleText: channel.channelHandleText,
        avatarUrl: channel.avatars?.isNotEmpty == true
            ? channel.avatars?.last.url
            : null,
        bannerUrl: channel.banners?.isNotEmpty == true
            ? channel.banners?.last.url
            : null,
        thumbnailUrl: channel.thumbnails?.isNotEmpty == true
            ? channel.thumbnails?.last.url
            : null,
        tvBannerUrl: channel.tvBanners?.isNotEmpty == true
            ? channel.tvBanners?.last.url
            : null,
        sections: sections,
        subscriberCount: channel.subscriberCount,
        videoCount: channel.videoCount,
      );
    } catch (e) {
      // Handle error
      log('Errore durante il recupero del canale: $e');
      rethrow;
    }
  }
}

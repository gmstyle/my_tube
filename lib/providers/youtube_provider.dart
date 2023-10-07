import 'dart:developer';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
// ignore: depend_on_referenced_packages
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:my_tube/models/video_category_mt.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'base_provider.dart';

class YoutubeProvider {
  final GoogleSignIn googleSignIn = BaseProvider.googleSignIn;
  final YoutubeExplode youtubeExplode = BaseProvider.youtubeExplode;
  Future<ChannelListResponse> getChannels() async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final channels = await youtubeApi.channels.list(
        ['snippet', 'contentDetails', 'statistics'],
        mine: true,
      );

      return channels;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<PlaylistListResponse> getPlaylists(String channelId) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final playlists = await youtubeApi.playlists.list(
        ['snippet', 'contentDetails'],
        channelId: channelId,
      );

      return playlists;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<PlaylistItemListResponse> getPlaylistItems(String playlistId) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final playlistItems = await youtubeApi.playlistItems.list(
        ['snippet', 'contentDetails'],
        playlistId: playlistId,
      );

      return playlistItems;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<VideoListResponse> getVideos(
      {String? nextPageToken, String? categoryId}) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final videos = await youtubeApi.videos.list(
          ['snippet', 'contentDetails', 'statistics'],
          chart: 'mostPopular',
          videoCategoryId: categoryId,
          maxResults: 20,
          pageToken: nextPageToken,
          regionCode: 'IT');

      return videos;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<SearchListResponse> getRelatedVideos(String videoId) async {
    try {
      final autClient = await _getAuthClient();
      final youtubeApi = YouTubeApi(autClient);

      final videos = await youtubeApi.search.list(
        ['snippet'],
        relatedToVideoId: videoId,
        type: ['video'],
      );

      return videos;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<SearchListResponse> searchContents(String query) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final results = await youtubeApi.search.list(
        ['snippet'],
        q: query,
        type: ['video', 'channel', 'playlist'],
        maxResults: 100,
      );

      return results;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<VideoListResponse> getVideosFromPlaylist(String playlistId) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final playlistItems = await youtubeApi.playlistItems.list(
        ['snippet', 'contentDetails'],
        playlistId: playlistId,
      );

      final videosId = playlistItems.items!
          .map((item) => item.contentDetails!.videoId!)
          .toList();

      final videos = await youtubeApi.videos.list(
        ['snippet', 'contentDetails', 'statistics'],
        id: videosId,
      );

      return videos;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<VideoListResponse> getVideosFromChannel(String channelId) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final playlists = await youtubeApi.playlists.list(
        ['snippet', 'contentDetails'],
        channelId: channelId,
      );

      final playlistId = playlists.items!.first.id!;

      return await getVideosFromPlaylist(playlistId);
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<VideoListResponse> getVideosFromChannelId(String channelId) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final playlists = await youtubeApi.playlists.list(
        ['snippet', 'contentDetails'],
        channelId: channelId,
      );

      final playlistId = playlists.items!.first.id!;

      return await getVideosFromPlaylist(playlistId);
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  /// Get trending videos
// TODO: dinamizzare la regione
  Future<VideoListResponse> getTrendingVideos() async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final videos = await youtubeApi.videos.list(
        ['snippet', 'contentDetails', 'statistics'],
        chart: 'mostPopular',
        regionCode: 'IT',
      );

      return videos;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  // Get video categories
  Future<VideoCategoryListResponse> getVideoCategories() async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final categories = await youtubeApi.videoCategories.list(
        ['snippet'],
        regionCode: 'IT',
      );

      return categories;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  // get the youtube stream url
  Future<String> getStreamUrl(String videoId) async {
    final manifest =
        await youtubeExplode.videos.streamsClient.getManifest(videoId);
    final streams = manifest.muxed.bestQuality;
    return streams.url.toString();
  }

  Future<auth.AuthClient> _getAuthClient() async {
    final autClient = await googleSignIn.authenticatedClient();
    if (autClient == null) {
      return Future.error('Error: autClient is null');
    }
    return autClient;
  }
}

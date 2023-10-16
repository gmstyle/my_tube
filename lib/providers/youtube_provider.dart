import 'dart:developer';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
// ignore: depend_on_referenced_packages
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
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
      {String? nextPageToken,
      String? categoryId,
      String? chart,
      String? myRating}) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final videos = await youtubeApi.videos.list(
          ['snippet', 'contentDetails', 'statistics'],
          chart: chart,
          myRating: myRating,
          videoCategoryId: categoryId,
          maxResults: 50,
          pageToken: nextPageToken,
          regionCode: 'IT');

      return videos;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  /// get video consigliati

  Future<SubscriptionListResponse> getSubscribedChannels(
      {String? nextPageToken}) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final response = await youtubeApi.subscriptions.list(
        ['snippet', 'contentDetails'],
        mine: true,
        maxResults: 50,
        pageToken: nextPageToken,
      );

      return response;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<SearchListResponse> searchContents(
      {required String query, String? nextPageToken}) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final response = await youtubeApi.search.list(
        ['snippet'],
        q: query,
        type: ['video', 'channel', 'playlist'],
        maxResults: 100,
        pageToken: nextPageToken,
      );

      return response;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<PlaylistItemListResponse> getVideosFromPlaylist(
      String playlistId) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final response = await youtubeApi.playlistItems.list(
        ['snippet', 'contentDetails'],
        playlistId: playlistId,
      );

      return response;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<SearchListResponse> getVideosFromChannel(String channelId) async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final videos = youtubeApi.search.list(
          ['snippet', 'contentDetails', 'statistics'],
          channelId: channelId, maxResults: 100);

      return videos;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  // Get subscriptions
  Future<SubscriptionListResponse> getSubscriptions() async {
    try {
      final autClient = await _getAuthClient();

      final youtubeApi = YouTubeApi(autClient);

      final subscriptions = await youtubeApi.subscriptions.list(
        ['snippet'],
        mine: true,
      );

      return subscriptions;
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

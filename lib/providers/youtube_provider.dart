import 'dart:developer';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/content/v2_1.dart';
import 'package:googleapis/youtube/v3.dart';

import 'base_provider.dart';

class YoutubeProvider extends BaseProvider {
  Future<ChannelListResponse> getChannels() async {
    try {
      final autClient = await googleSignIn.authenticatedClient();

      final youtubeApi = YouTubeApi(autClient!);

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
      final autClient = await googleSignIn.authenticatedClient();

      final youtubeApi = YouTubeApi(autClient!);

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
      final autClient = await googleSignIn.authenticatedClient();

      final youtubeApi = YouTubeApi(autClient!);

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

  Future<VideoListResponse> getVideos() async {
    try {
      final autClient = await googleSignIn.authenticatedClient();

      final youtubeApi = YouTubeApi(autClient!);

      final videos = await youtubeApi.videos.list(
        ['snippet', 'contentDetails', 'statistics'],
      );

      return videos;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<SearchListResponse> getRelatedVideos(String videoId) async {
    try {
      final autClient = await googleSignIn.authenticatedClient();

      final youtubeApi = YouTubeApi(autClient!);

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

  Future<SearchListResponse> searchVideos(String query) async {
    try {
      final autClient = await googleSignIn.authenticatedClient();

      final youtubeApi = YouTubeApi(autClient!);

      final videos = await youtubeApi.search.list(
        ['snippet'],
        q: query,
        type: ['video'],
      );

      return videos;
    } catch (error) {
      log('Error: $error');
      return Future.error('Error: $error');
    }
  }

  Future<VideoListResponse> getVideosFromPlaylist(String playlistId) async {
    try {
      final autClient = await googleSignIn.authenticatedClient();

      final youtubeApi = YouTubeApi(autClient!);

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
      final autClient = await googleSignIn.authenticatedClient();

      final youtubeApi = YouTubeApi(autClient!);

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
      final autClient = await googleSignIn.authenticatedClient();

      final youtubeApi = YouTubeApi(autClient!);

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
      final autClient = await googleSignIn.authenticatedClient();

      final youtubeApi = YouTubeApi(autClient!);

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
}

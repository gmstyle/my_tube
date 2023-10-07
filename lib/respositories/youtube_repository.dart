import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/video_category_mt.dart';
import 'package:my_tube/providers/youtube_provider.dart';

class YoutubeRepository {
  YoutubeRepository({required this.youtubeProvider});

  final YoutubeProvider youtubeProvider;

  Future<ChannelListResponse> getChannels() async {
    return await youtubeProvider.getChannels();
  }

  Future<PlaylistListResponse> getPlaylists(String channelId) async {
    return await youtubeProvider.getPlaylists(channelId);
  }

  Future<PlaylistItemListResponse> getPlaylistItems(String playlistId) async {
    return await youtubeProvider.getPlaylistItems(playlistId);
  }

  Future<VideoListResponse> getVideos(
      {String? nextPageToken, String? categoryId}) async {
    return await youtubeProvider.getVideos(
        nextPageToken: nextPageToken, categoryId: categoryId);
  }

  Future<VideoListResponse> getTrendigVideos() async {
    return await youtubeProvider.getTrendingVideos();
  }

  Future<String> getStreamUrl(String videoId) async {
    return await youtubeProvider.getStreamUrl(videoId);
  }

  Future<List<VideoCategoryMT>> getVideoCategories() async {
    final response = await youtubeProvider.getVideoCategories();
    return response.items!
        .map((e) => VideoCategoryMT(
              id: e.id!,
              title: e.snippet!.title!,
            ))
        .toList();
  }

  //TODO: Implementare gli altri metodi
}

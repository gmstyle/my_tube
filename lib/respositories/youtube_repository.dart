import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/video_category_mt.dart';
import 'package:my_tube/providers/youtube_provider.dart';
import 'package:my_tube/respositories/mappers/video_mapper.dart';

class YoutubeRepository {
  YoutubeRepository({required this.youtubeProvider, required this.videoMapper});

  final YoutubeProvider youtubeProvider;
  final VideoMapper videoMapper;

  Future<ChannelListResponse> getChannels() async {
    return await youtubeProvider.getChannels();
  }

  Future<PlaylistListResponse> getPlaylists(String channelId) async {
    return await youtubeProvider.getPlaylists(channelId);
  }

  Future<PlaylistItemListResponse> getPlaylistItems(String playlistId) async {
    return await youtubeProvider.getPlaylistItems(playlistId);
  }

  Future<Map<String, dynamic>> getVideos(
      {String? nextPageToken, String? categoryId}) async {
    final response = await youtubeProvider.getVideos(
        nextPageToken: nextPageToken, categoryId: categoryId);
    final videos =
        response.items!.map((e) => videoMapper.mapToModel(e)).toList();
    return {
      'videos': videos,
      'nextPageToken': response.nextPageToken,
    };
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

  Future<List<SearchResult>?> searchContents(String query) async {
    final response = await youtubeProvider.searchContents(query);
    return response.items;
  }

  //TODO: Implementare gli altri metodi
}

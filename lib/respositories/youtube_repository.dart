import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/video_category_mt.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/providers/youtube_provider.dart';
import 'package:my_tube/respositories/mappers/search_mapper.dart';
import 'package:my_tube/respositories/mappers/video_mapper.dart';

class YoutubeRepository {
  YoutubeRepository(
      {required this.youtubeProvider,
      required this.videoMapper,
      required this.searchMapper});

  final YoutubeProvider youtubeProvider;
  final VideoMapper videoMapper;
  final SearchMapper searchMapper;

  Future<ChannelListResponse> getChannels() async {
    return await youtubeProvider.getChannels();
  }

  Future<PlaylistListResponse> getPlaylists(String channelId) async {
    return await youtubeProvider.getPlaylists(channelId);
  }

  Future<PlaylistItemListResponse> getPlaylistItems(String playlistId) async {
    return await youtubeProvider.getPlaylistItems(playlistId);
  }

  Future<VideoResponseMT> getTrendingVideos(
      {String? nextPageToken, String? categoryId}) async {
    final response = await youtubeProvider.getTrendingVideos(
        nextPageToken: nextPageToken, categoryId: categoryId);
    return videoMapper.mapToModel(response);
  }

  Future<VideoResponseMT> getHomeVideos(
      {String? nextPageToken, String? categoryId}) async {
    final response = await youtubeProvider.getHomeVideos(
        nextPageToken: nextPageToken, categoryId: categoryId);
    return videoMapper.mapToModel(response);
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

  Future<List<VideoMT>?> searchContents(String query) async {
    final response = await youtubeProvider.searchContents(query);
    return response.items?.map((e) => searchMapper.mapToModel(e)).toList();
  }

  //TODO: Implementare gli altri metodi
}

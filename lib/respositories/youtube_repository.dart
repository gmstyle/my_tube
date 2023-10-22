import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/suggestion_response_mt.dart';
import 'package:my_tube/models/video_category_mt.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/providers/youtube_provider.dart';
import 'package:my_tube/respositories/mappers/subscription_mapper.dart';
import 'package:my_tube/respositories/mappers/search_mapper.dart';
import 'package:my_tube/respositories/mappers/video_mapper.dart';
import 'package:xml/xml.dart' as xml;

class YoutubeRepository {
  YoutubeRepository(
      {required this.youtubeProvider,
      required this.videoMapper,
      required this.searchMapper,
      required this.activityMapper});

  final YoutubeProvider youtubeProvider;
  final VideoMapper videoMapper;
  final SearchMapper searchMapper;
  final SubscriptionMapper activityMapper;

  Future<List<VideoCategoryMT>> getVideoCategories() async {
    final response = await youtubeProvider.getVideoCategories();
    return response.items!
        .map((e) => VideoCategoryMT(
              id: e.id!,
              title: e.snippet!.title!,
            ))
        .toList();
  }

  Future<VideoResponseMT> getVideos(
      {String? nextPageToken,
      String? categoryId,
      String? chart,
      String? myRating}) async {
    final response = await youtubeProvider.getVideos(
      nextPageToken: nextPageToken,
      categoryId: categoryId,
      chart: chart,
      myRating: myRating,
    );
    return videoMapper.mapToModel(response);
  }

  Future<VideoResponseMT> searchContents(
      {required String query, String? nextPageToken}) async {
    final response = await youtubeProvider.searchContents(
        query: query, nextPageToken: nextPageToken);
    return searchMapper.mapToModel(response);
  }

  Future<VideoResponseMT> getSubscribedChannels({String? nextPageToken}) async {
    final response = await youtubeProvider.getSubscribedChannels(
        nextPageToken: nextPageToken);
    return activityMapper.mapToModel(response);
  }

  Future<PlaylistListResponse> getPlaylists(String channelId) async {
    return await youtubeProvider.getPlaylists(channelId);
  }

  Future<PlaylistItemListResponse> getPlaylistItems(String playlistId) async {
    return await youtubeProvider.getPlaylistItems(playlistId);
  }

  Future<String> getStreamUrl(String videoId) async {
    return await youtubeProvider.getStreamUrl(videoId);
  }

  Future<SuggestionResponseMT> getSearchSuggestions(String query) async {
    final response = await youtubeProvider.getSearchSuggestions(query);
    final xmlResponse = xml.XmlDocument.parse(response);
    final suggestions = xmlResponse
        .findAllElements('suggestion')
        .map((e) => e.getAttribute('data')!)
        .toList();
    final suggestionMap = {
      'query': query,
      'suggestions': suggestions,
    };
    return SuggestionResponseMT.fromJson(suggestionMap);
  }
}

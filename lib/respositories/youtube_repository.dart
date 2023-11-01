import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/channel_mt.dart';
import 'package:my_tube/models/suggestion_response_mt.dart';
import 'package:my_tube/models/video_category_mt.dart';
import 'package:my_tube/models/resource_mt.dart';
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

  Future<ResponseMT> getVideos(
      {String? nextPageToken,
      String? categoryId,
      String? chart,
      String? myRating,
      List<String>? videoIds}) async {
    final response = await youtubeProvider.getVideos(
      nextPageToken: nextPageToken,
      categoryId: categoryId,
      chart: chart,
      myRating: myRating,
      videoIds: videoIds,
    );
    return videoMapper.mapToModel(response);
  }

  Future<ResponseMT> searchContents(
      {required String query, String? nextPageToken}) async {
    final response = await youtubeProvider.searchContents(
        query: query, nextPageToken: nextPageToken);
    return searchMapper.mapToModel(response);
  }

  Future<ResponseMT> getSubscribedChannels({String? nextPageToken}) async {
    final response = await youtubeProvider.getSubscribedChannels(
        nextPageToken: nextPageToken);
    return activityMapper.mapToModel(response);
  }

  Future<PlaylistListResponse> getPlaylists(String channelId) async {
    return await youtubeProvider.getPlaylists(channelId);
  }

  Future<ResponseMT> getPlaylistItems(
      {required String playlistId, String? nextPageToken}) async {
    final response = await youtubeProvider.getPlaylistItems(
        playlistId: playlistId, nextPageToken: nextPageToken);
    final videoIds =
        response.items?.map((e) => e.snippet!.resourceId!.videoId!).toList();
    final videosResponse = await getVideos(videoIds: videoIds);
    return videosResponse;
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

  Future<ChannelMT> getChannelDetails(String channelId) async {
    final channelResponse = await youtubeProvider.getChannelDetails(channelId);
    final channel = channelResponse.items?.first;
    final playlistId = channel?.contentDetails?.relatedPlaylists?.uploads;
    final playlistItems = await getPlaylistItems(playlistId: playlistId!);
    final channelVideos = playlistItems.resources;

    return ChannelMT(
      id: channel?.id,
      title: channel?.snippet?.title,
      description: channel?.snippet?.description,
      thumbnailUrl: channel?.snippet?.thumbnails?.high?.url,
      videoCount: channel?.statistics?.videoCount,
      subscriberCount: channel?.statistics?.subscriberCount,
      viewCount: channel?.statistics?.viewCount,
      videos: channelVideos,
    );
  }
}

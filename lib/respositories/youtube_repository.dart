import 'package:googleapis/youtube/v3.dart';
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

  Future<VideoListResponse> getVideos({String? nextPageToken}) async {
    return await youtubeProvider.getVideos(nextPageToken: nextPageToken);
  }

  Future<VideoListResponse> getTrendigVideos() async {
    return await youtubeProvider.getTrendingVideos();
  }

  Future<String> getStreamUrl(String videoId) async {
    return await youtubeProvider.getStreamUrl(videoId);
  }

  //TODO: Implementare gli altri metodi
}

import 'package:hive_ce/hive.dart';
import 'package:innertube_dart/enums/enums.dart';
import 'package:innertube_dart/innertube.dart';
import 'package:innertube_dart/models/responses/channel.dart';
import 'package:innertube_dart/models/responses/music_home_response.dart';
import 'package:innertube_dart/models/responses/playlist.dart';
import 'package:innertube_dart/models/responses/search_response.dart';
import 'package:innertube_dart/models/responses/trending_response.dart';
import 'package:innertube_dart/models/responses/video.dart';
import 'package:my_tube/providers/base_provider.dart';
import 'package:my_tube/utils/utils.dart';

class InnertubeProvider extends BaseProvider {
  final settingsBox = Hive.box('settings');

  Future<Video> getVideo(String videoId, bool? withStreamUrl) async {
    final innertube = await _client;
    final video = await innertube.getVideo(
        videoId: videoId, withStreamingUrl: withStreamUrl ?? true);
    return video;
  }

  Future<Playlist> getPlaylist(String playlistId,
      {bool getVideos = true}) async {
    final innertube = await _client;
    final playlist = await innertube.getPlaylist(
        playlistId: playlistId, getVideos: getVideos);
    return playlist;
  }

  Future<TrendingResponse> getTrending(
      TrendingCategory trendingCategory) async {
    final innertube = await _client;
    final response =
        await innertube.getTrending(trendingCategory: trendingCategory);
    return response;
  }

  Future<MusicHomeResponse> getMusicHome() async {
    final innertube = await _client;
    final response = await innertube.getMusicHome();
    return response;
  }

  Future<List<String>?> getSearchSuggestions(String query) async {
    final innertube = await _client;
    final response = await innertube.suggestQueries(query: query);
    return response;
  }

  Future<SearchResponse> searchContents(
      {required String query, String? nextPageToken}) async {
    final innertube = await _client;
    final response =
        await innertube.search(query: query, continuationToken: nextPageToken);
    return response;
  }

  Future<Channel> getChannel(String channelId) async {
    final innertube = await _client;
    final response = await innertube.getChannel(channelId: channelId);
    return response;
  }

  Future<Innertube> get _client async {
    String countryCode;
    //recuperare il locale dalle impostazioni
    if (settingsBox.containsKey('countryCode')) {
      countryCode = settingsBox.get('countryCode');
    } else {
      //se non presente recuperarlo da internet
      countryCode = await getCountryCode();
      settingsBox.put('countryCode', countryCode);
    }

    final locale = Utils.getLocaleFromCountryCode(countryCode);
    return Innertube(locale: locale);
  }
}

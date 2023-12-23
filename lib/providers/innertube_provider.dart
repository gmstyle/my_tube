import 'package:innertube_dart/enums/enums.dart';
import 'package:innertube_dart/innertube.dart';
import 'package:innertube_dart/models/responses/music_home_response.dart';
import 'package:innertube_dart/models/responses/playlist.dart';
import 'package:innertube_dart/models/responses/trending_response.dart';
import 'package:innertube_dart/models/responses/video.dart';
import 'package:my_tube/providers/base_provider.dart';
import 'package:my_tube/utils/utils.dart';

class InnertubeProvider extends BaseProvider {
  Future<Video> getVideo(String videoId) async {
    final innertube = await _getClient();
    final video = await innertube.getVideo(videoId: videoId);
    return video;
  }

  Future<Playlist> getPlaylist(String playlistId) async {
    final innertube = await _getClient();
    final playlist = await innertube.getPlaylist(playlistId: playlistId);
    return playlist;
  }

  Future<TrendingResponse> getTrending(
      TrendingCategory trendingCategory) async {
    final innertube = await _getClient();
    final response =
        await innertube.getTrending(trendingCategory: trendingCategory);
    return response;
  }

  Future<MusicHomeResponse> getMusicHome() async {
    final innertube = await _getClient();
    final response = await innertube.getMusicHome();
    return response;
  }

  Future<Innertube> _getClient() async {
    final countryCode = await getCountryCode();
    final locale = Utils.getLocaleFromCountryCode(countryCode);
    return Innertube(locale: locale);
  }
}

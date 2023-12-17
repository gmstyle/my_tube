import 'package:innertube_dart/enums/enums.dart';
import 'package:innertube_dart/innertube.dart';
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

  Future<TrendingResponse> getTrendingMusic() async {
    final innertube = await _getClient();
    final response =
        await innertube.getTrending(trendingCategory: TrendingCategory.music);
    return response;
  }

  Future<Innertube> _getClient() async {
    final countryCode = await getCountryCode();
    final locale = Utils.getLocaleFromCountryCode(countryCode);
    return Innertube(locale: locale);
  }
}

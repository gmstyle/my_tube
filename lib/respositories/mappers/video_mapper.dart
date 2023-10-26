import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/respositories/mappers/base_mapper.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/utils/utils.dart';

class VideoMapper extends BaseMapper<VideoListResponse, ResponseMT> {
  @override
  ResponseMT mapToModel(VideoListResponse data) {
    final videos = data.items!
        .map((e) => ResourceMT(
            id: e.id,
            title: e.snippet?.title,
            description: e.snippet?.description,
            channelTitle: e.snippet?.channelTitle,
            thumbnailUrl: e.snippet?.thumbnails?.medium?.url,
            kind: e.kind,
            channelId: e.snippet?.channelId,
            streamUrl: '',
            duration: Utils.parseDurationStringToMilliseconds(
                e.contentDetails?.duration)))
        .toList();
    return ResponseMT(resources: videos, nextPageToken: data.nextPageToken);
  }

  @override
  VideoListResponse mapToData(ResponseMT model) {
    throw UnimplementedError();
  }
}

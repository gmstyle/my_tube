import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/respositories/mappers/base_mapper.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/utils/utils.dart';

class VideoMapper extends BaseMapper<VideoListResponse, VideoResponseMT> {
  @override
  VideoResponseMT mapToModel(VideoListResponse data) {
    final videos = data.items!
        .map((e) => VideoMT(
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
    return VideoResponseMT(videos: videos, nextPageToken: data.nextPageToken);
  }

  @override
  VideoListResponse mapToData(VideoResponseMT model) {
    throw UnimplementedError();
  }
}

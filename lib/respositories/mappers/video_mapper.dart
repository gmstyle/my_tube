import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/respositories/mappers/base_mapper.dart';
import 'package:my_tube/models/video_mt.dart';

class VideoMapper extends BaseMapper<VideoListResponse, VideoResponse> {
  @override
  VideoResponse mapToModel(VideoListResponse data) {
    final videos = data.items!
        .map((e) => VideoMT(
              id: e.id!,
              title: e.snippet!.title!,
              channelTitle: e.snippet!.channelTitle!,
              thumbnailUrl: e.snippet!.thumbnails!.medium!.url!,
              kind: e.kind!,
            ))
        .toList();
    return VideoResponse(
      videos: videos,
      nextPageToken: data.nextPageToken!,
    );
  }

  @override
  VideoListResponse mapToData(VideoResponse model) {
    throw UnimplementedError();
  }
}

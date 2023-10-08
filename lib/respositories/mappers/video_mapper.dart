import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/respositories/mappers/base_mapper.dart';
import 'package:my_tube/models/video_mt.dart';

class VideoMapper extends BaseMapper<Video, VideoMT> {
  @override
  VideoMT mapToModel(Video data) {
    return VideoMT(
      id: data.id!,
      title: data.snippet!.title!,
      channelTitle: data.snippet!.channelTitle!,
      thumbnailUrl: data.snippet!.thumbnails!.high!.url!,
    );
  }

  @override
  Video mapToData(VideoMT model) {
    throw UnimplementedError();
  }
}

import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/respositories/mappers/base_mapper.dart';
import 'package:my_tube/utils/utils.dart';

class SearchMapper extends BaseMapper<SearchListResponse, VideoResponseMT> {
  @override
  VideoResponseMT mapToModel(SearchListResponse data) {
    final videos = data.items!
        .map((e) => VideoMT(
              id: e.id?.videoId,
              title: e.snippet?.title,
              description: e.snippet?.description,
              channelTitle: e.snippet?.channelTitle,
              thumbnailUrl: e.snippet?.thumbnails?.medium?.url,
              kind: e.id?.kind,
              channelId: e.snippet?.channelId,
              streamUrl: '',
              duration: 0,
            ))
        .toList();
    return VideoResponseMT(
      videos: videos,
      nextPageToken: data.nextPageToken,
    );
  }

  @override
  SearchListResponse mapToData(VideoResponseMT model) {
    // TODO: implement mapToData
    throw UnimplementedError();
  }
}

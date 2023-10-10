import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/respositories/mappers/base_mapper.dart';

class SearchMapper extends BaseMapper<SearchResult, VideoMT> {
  @override
  VideoMT mapToModel(SearchResult data) {
    return VideoMT(
      id: data.id?.videoId,
      title: data.snippet?.title,
      channelTitle: data.snippet?.channelTitle,
      thumbnailUrl: data.snippet?.thumbnails?.medium?.url,
      kind: data.id?.kind,
      channelId: data.snippet?.channelId,
    );
  }

  @override
  SearchResult mapToData(VideoMT model) {
    // TODO: implement mapToData
    throw UnimplementedError();
  }
}

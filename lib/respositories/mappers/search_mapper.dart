import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/respositories/mappers/base_mapper.dart';

class SearchMapper extends BaseMapper<SearchResult, VideoMT> {
  @override
  VideoMT mapToModel(SearchResult data) {
    return VideoMT(
      id: data.id?.videoId ?? 'a',
      title: data.snippet?.title ?? 'b',
      channelTitle: data.snippet?.channelTitle ?? 'c',
      thumbnailUrl: data.snippet?.thumbnails?.medium?.url ?? 'd',
      kind: data.id?.kind ?? 'e',
    );
  }

  @override
  SearchResult mapToData(VideoMT model) {
    // TODO: implement mapToData
    throw UnimplementedError();
  }
}

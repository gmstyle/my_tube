import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/mappers/base_mapper.dart';

class SearchMapper extends BaseMapper<SearchListResponse, ResponseMT> {
  @override
  ResponseMT mapToModel(SearchListResponse data) {
    final videos = data.items!
        .map((e) => ResourceMT(
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
    return ResponseMT(
      resources: videos,
      nextPageToken: data.nextPageToken,
    );
  }

  @override
  SearchListResponse mapToData(ResponseMT model) {
    // TODO: implement mapToData
    throw UnimplementedError();
  }
}

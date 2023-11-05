import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/mappers/base_mapper.dart';

class SubscriptionMapper
    extends BaseMapper<SubscriptionListResponse, ResponseMT> {
  @override
  ResponseMT mapToModel(SubscriptionListResponse data) {
    final resources = data.items!
        .map((e) => ResourceMT(
              id: e.id,
              title: e.snippet?.title,
              description: e.snippet?.description,
              kind: e.snippet?.resourceId?.kind,
              channelId: e.snippet?.resourceId?.channelId,
              thumbnailUrl: e.snippet?.thumbnails?.high?.url,
              channelTitle: e.snippet?.channelTitle,
              playlistId: '',
              streamUrl: '',
              duration: 0,
            ))
        .toList();

    return ResponseMT(
      resources: resources,
      nextPageToken: data.nextPageToken,
    );
  }

  @override
  SubscriptionListResponse mapToData(ResponseMT model) {
    throw UnimplementedError();
  }
}

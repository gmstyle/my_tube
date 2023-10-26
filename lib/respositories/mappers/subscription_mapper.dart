import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/respositories/mappers/base_mapper.dart';

class SubscriptionMapper
    extends BaseMapper<SubscriptionListResponse, VideoResponseMT> {
  @override
  VideoResponseMT mapToModel(SubscriptionListResponse data) {
    final activities = data.items!
        .map((e) => VideoMT(
              id: e.id,
              title: e.snippet?.title,
              description: e.snippet?.description,
              kind: e.snippet?.resourceId?.kind,
              channelId: e.snippet?.resourceId?.channelId,
              thumbnailUrl: e.snippet?.thumbnails?.medium?.url,
              channelTitle: e.snippet?.channelTitle,
              streamUrl: '',
              duration: 0,
            ))
        .toList();

    return VideoResponseMT(
      videos: activities,
      nextPageToken: data.nextPageToken,
    );
  }

  @override
  SubscriptionListResponse mapToData(VideoResponseMT model) {
    throw UnimplementedError();
  }
}

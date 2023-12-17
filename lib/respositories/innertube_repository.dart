import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/providers/innertube_provider.dart';

class InnertubeRepository {
  InnertubeRepository({required this.innertubeProvider});

  final InnertubeProvider innertubeProvider;

  Future<ResourceMT> getVideo(String videoId) async {
    final video = await innertubeProvider.getVideo(videoId);
    return ResourceMT(
      id: video.videoId,
      title: video.title,
      description: video.description,
      channelTitle: video.author,
      thumbnailUrl: video.thumbnails?.first.url,
      kind: null,
      channelId: video.channelId,
      playlistId: '',
      streamUrl: video.muxedStreamingUrl,
      duration: video.durationMs != null ? int.parse(video.durationMs!) : null,
    );
  }
}

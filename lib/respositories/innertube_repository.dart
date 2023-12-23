import 'package:innertube_dart/enums/enums.dart';
import 'package:my_tube/models/music_home_mt.dart';
import 'package:my_tube/models/playlist_mt.dart';
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
      thumbnailUrl: video.thumbnails?.last.url,
      kind: null,
      channelId: video.channelId,
      playlistId: '',
      streamUrl: video.muxedStreamingUrl,
      duration: video.durationMs != null ? int.parse(video.durationMs!) : null,
    );
  }

  Future<ResponseMT> getTrending(TrendingCategory trendingCategory) async {
    final response = await innertubeProvider.getTrending(trendingCategory);
    if (response.videos != null) {
      final resources = response.videos!
          .map((video) => ResourceMT(
                id: video.videoId,
                title: video.title,
                description: video.description,
                channelTitle: video.author,
                thumbnailUrl: video.thumbnails?.first.url,
                kind: null,
                channelId: video.channelId,
                playlistId: '',
                streamUrl: video.muxedStreamingUrl,
                duration: video.durationMs != null
                    ? int.parse(video.durationMs!)
                    : null,
              ))
          .toList();
      return ResponseMT(resources: resources, nextPageToken: null);
    } else {
      return const ResponseMT(resources: [], nextPageToken: null);
    }
  }

  Future<MusicHomeMT> getMusicHome() async {
    final response = await innertubeProvider.getMusicHome();
    final carouselVideos = response.carouselVideos
        ?.map((video) => ResourceMT(
              id: video.videoId,
              title: video.title,
              description: video.description,
              channelTitle: video.author,
              thumbnailUrl: video.thumbnails?.last.url,
              kind: null,
              channelId: video.channelId,
              playlistId: null,
              streamUrl: video.muxedStreamingUrl,
              duration: video.durationMs != null
                  ? int.parse(video.durationMs!)
                  : null,
            ))
        .toList();
    final sections = response.sections!
        .map((section) => MusicSectionMT(
              title: section.title,
              playlistId: section.playlistId,
              videos: section.videos
                  ?.map((video) => ResourceMT(
                        id: video.videoId,
                        title: video.title,
                        description: video.description,
                        channelTitle: video.author,
                        thumbnailUrl: video.thumbnails?.last.url,
                        kind: null,
                        channelId: video.channelId,
                        playlistId: null,
                        streamUrl: video.muxedStreamingUrl,
                        duration: video.durationMs != null
                            ? int.parse(video.durationMs!)
                            : null,
                      ))
                  .toList(),
              playlists: section.playlists
                  ?.map((playlist) => PlaylistMT(
                      id: playlist.playlistId,
                      channelId: null,
                      title: playlist.title,
                      description: playlist.description,
                      thumbnailUrl: playlist.thumbnails?.last.url,
                      itemCount: int.tryParse(playlist.videoCount ?? '0'),
                      videos: playlist.videos
                          ?.map((video) => ResourceMT(
                                id: video.videoId,
                                title: video.title,
                                description: video.description,
                                channelTitle: video.author,
                                thumbnailUrl: video.thumbnails?.last.url,
                                kind: null,
                                channelId: video.channelId,
                                playlistId: '',
                                streamUrl: video.muxedStreamingUrl,
                                duration: video.durationMs != null
                                    ? int.parse(video.durationMs!)
                                    : null,
                              ))
                          .toList()))
                  .toList(),
            ))
        .toList();
    return MusicHomeMT(
      title: response.title,
      description: response.description,
      carouselVideos: carouselVideos,
      sections: sections,
    );
  }

  Future<PlaylistMT> getPlaylist(String playlistId) async {
    final playlist = await innertubeProvider.getPlaylist(playlistId);
    final resources = playlist.videos!
        .map((video) => ResourceMT(
              id: video.videoId,
              title: video.title,
              description: video.description,
              channelTitle: video.author,
              thumbnailUrl: video.thumbnails?.first.url,
              kind: null,
              channelId: video.channelId,
              playlistId: '',
              streamUrl: video.muxedStreamingUrl,
              duration: video.durationMs != null
                  ? int.parse(video.durationMs!)
                  : null,
            ))
        .toList();
    return PlaylistMT(
        id: playlist.playlistId,
        channelId: null,
        title: playlist.title,
        description: playlist.description,
        thumbnailUrl: playlist.thumbnails?.last.url,
        itemCount: resources.length,
        videos: resources);
  }
}

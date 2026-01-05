import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/respositories/favorite_repository.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'dart:math';

part 'musci_tab_event.dart';
part 'music_tab_state.dart';

class MusicTabBloc extends Bloc<MusicTabEvent, MusicTabState> {
  final YoutubeExplodeRepository youtubeExplodeRepository;
  final FavoriteRepository favoriteRepository;

  MusicTabBloc(
      {required this.youtubeExplodeRepository,
      required this.favoriteRepository})
      : super(const MusicTabState.initial()) {
    on<GetMusicTabContent>(_onGetMusicTabContent);
  }

  Future<void> _onGetMusicTabContent(
      GetMusicTabContent event, Emitter<MusicTabState> emit) async {
    emit(const MusicTabState.loading());
    try {
      final favoriteVideos = await favoriteRepository.favoriteVideos;
      final favoriteChannels = await favoriteRepository.favoriteChannels;

      final hasFavorites =
          favoriteVideos.isNotEmpty || favoriteChannels.isNotEmpty;

      List<VideoTile> newReleases = [];
      List<VideoTile> discoverRelated = [];
      VideoTile? discoverVideo;
      List<VideoTile> trending = [];
      bool isInternationalTrending = false;

      // 1. New Releases (From Favorite Channels)
      if (favoriteChannels.isNotEmpty) {
        final recentUploadsFutures = favoriteChannels.map((channel) async {
          try {
            final channelData =
                await youtubeExplodeRepository.getChannel(channel.id);
            // Get latest 2 videos
            final uploads = channelData['videos'] as List<VideoTile>;
            return uploads.take(2).toList();
          } catch (e) {
            return <VideoTile>[];
          }
        });
        final nestedUploads = await Future.wait(recentUploadsFutures);
        newReleases = nestedUploads.expand((i) => i).toList();
      }

      // 2. Discover (From Favorite Videos)
      if (favoriteVideos.isNotEmpty) {
        final random = Random();
        discoverVideo = favoriteVideos[random.nextInt(favoriteVideos.length)];
        discoverRelated =
            await youtubeExplodeRepository.getRelatedVideos(discoverVideo.id);
      }

      // 4. Trending / International
      if (!hasFavorites) {
        isInternationalTrending = true;
        final results = await Future.wait([
          youtubeExplodeRepository.getTrending('Music'),
        ]);
        trending = results[0];
      } else {
        trending = await youtubeExplodeRepository.getTrending('Music');
      }

      emit(MusicTabState.loaded(
        newReleases: newReleases,
        discoverVideo: discoverVideo,
        discoverRelated: discoverRelated,
        trending: trending,
        isInternationalTrending: isInternationalTrending,
      ));
    } catch (e) {
      emit(MusicTabState.error(error: e.toString()));
    }
  }
}

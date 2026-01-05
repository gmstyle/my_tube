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
        // Sort by date presumably, but for now just shuffle or keep order
        // Ideally we would parse dates but tiles might not have full date objects easily accessible
        // Let's settle for simple aggregation for now.
      }

      // 2. Discover (From Favorite Videos)
      if (favoriteVideos.isNotEmpty) {
        final random = Random();
        discoverVideo = favoriteVideos[random.nextInt(favoriteVideos.length)];
        discoverRelated =
            await youtubeExplodeRepository.getRelatedVideos(discoverVideo.id);
      }

      // 3. Trending / International
      if (!hasFavorites) {
        // Fallback for new users: Fetch generic popular music
        isInternationalTrending = true;

        // Parallel fetch for different "international" vibes
        final results = await Future.wait([
          youtubeExplodeRepository
              .getTrending('Music'), // Generic Music Trending
          // Since we can't easily query "Global Top 50" specifically without a playlist ID,
          // we use different search queries simulated in getTrending if needed, or stick to 'Music' category.
          // For better variety, let's search for "Global Top Songs" manually via search if possible,
          // but `getTrending` with 'Music' is the safest robust generic fallback.
        ]);

        // If we want more variety, we could add search calls:
        // final globalHits = await youtubeExplodeRepository.searchContents(query: "Global Top Hits");

        trending = results[0];
      } else {
        // User has favorites, show trending at bottom
        trending = await youtubeExplodeRepository.getTrending('Music');
      }

      emit(MusicTabState.loaded(
        favorites: favoriteVideos,
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

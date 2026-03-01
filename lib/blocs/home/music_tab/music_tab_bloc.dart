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
      // Favorites vengono dai DB locale – veloci, in sequenza
      final favoriteVideos = await favoriteRepository.favoriteVideos;
      final favoriteChannels = await favoriteRepository.favoriteChannels;

      final hasFavorites =
          favoriteVideos.isNotEmpty || favoriteChannels.isNotEmpty;

      // Scegli il seed per Discover prima di avviare i futures paralleli
      VideoTile? discoverVideo;
      if (favoriteVideos.isNotEmpty) {
        discoverVideo = favoriteVideos[Random().nextInt(favoriteVideos.length)];
      }

      // Le tre sezioni di rete partono tutte in parallelo
      final results = await Future.wait<List<VideoTile>>([
        // 1. New Releases (From Favorite Channels)
        _fetchNewReleases(favoriteChannels),
        // 2. Discover (From Favorite Videos)
        discoverVideo != null
            ? youtubeExplodeRepository.getRelatedVideos(discoverVideo.id)
            : Future.value(<VideoTile>[]),
        // 3. Trending / International
        youtubeExplodeRepository.getTrending('Music'),
      ]);

      emit(MusicTabState.loaded(
        newReleases: results[0],
        discoverVideo: discoverVideo,
        discoverRelated: results[1],
        trending: results[2],
        isInternationalTrending: !hasFavorites,
      ));
    } catch (e) {
      emit(MusicTabState.error(error: e.toString()));
    }
  }

  /// Recupera gli ultimi 2 upload da ogni canale preferito in parallelo.
  Future<List<VideoTile>> _fetchNewReleases(dynamic favoriteChannels) async {
    if ((favoriteChannels as List).isEmpty) return [];
    final futures = favoriteChannels.map((channel) async {
      try {
        final channelData =
            await youtubeExplodeRepository.getChannel(channel.id);
        final uploads = channelData['videos'] as List<VideoTile>;
        return uploads.take(2).toList();
      } catch (_) {
        return <VideoTile>[];
      }
    });
    final nested = await Future.wait(futures);
    return nested.expand((i) => i).toList();
  }
}

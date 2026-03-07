import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/respositories/favorite_repository.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';

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

  final Box _settingsBox = Hive.box('settings');
  static const _discoverSeedKey = 'musicDiscoverSeedIndex';

  // Durata minima per escludere shorts (< 90s) e massima per escludere
  // compilazioni (> 15 min) nella sezione Discover.
  static const _discoverMinDuration = Duration(seconds: 90);
  static const _discoverMaxDuration = Duration(minutes: 15);

  Future<void> _onGetMusicTabContent(
      GetMusicTabContent event, Emitter<MusicTabState> emit) async {
    emit(const MusicTabState.loading());
    try {
      // Favorites vengono dai DB locale – veloci, in sequenza
      final favoriteVideos = await favoriteRepository.favoriteVideos;
      final favoriteChannels = await favoriteRepository.favoriteChannels;

      final hasFavorites =
          favoriteVideos.isNotEmpty || favoriteChannels.isNotEmpty;

      // Priorità 2+5: scegli seed Discover preferendo video con tag musicale;
      // l'indice avanza ad ogni apertura (rotazione) invece di essere puramente random.
      VideoTile? discoverVideo;
      if (favoriteVideos.isNotEmpty) {
        final musicSeeds =
            favoriteVideos.where((v) => v.artist != null).toList();
        final pool = musicSeeds.isNotEmpty ? musicSeeds : favoriteVideos;
        // Priorità 5: leggi l'indice corrente e avanzalo per la prossima apertura
        final currentIdx =
            (_settingsBox.get(_discoverSeedKey, defaultValue: 0) as int) %
                pool.length;
        discoverVideo = pool[currentIdx];
        _settingsBox.put(_discoverSeedKey, currentIdx + 1);
      }

      // Priorità 8: se ci sono artisti tra i preferiti, usa il trending personalizzato
      final uniqueArtists = favoriteVideos
          .map((v) => v.artist)
          .whereType<String>()
          .toSet()
          .toList();

      // Le tre sezioni di rete partono tutte in parallelo
      final results = await Future.wait<List<VideoTile>>([
        // 1. New Releases (From Favorite Channels)
        _fetchNewReleases(favoriteChannels),
        // 2. Discover (From Favorite Videos)
        discoverVideo != null
            ? youtubeExplodeRepository.getRelatedVideos(discoverVideo.id)
            : Future.value(<VideoTile>[]),
        // 3. Trending: personalizzato per artisti noti, generico altrimenti
        uniqueArtists.isNotEmpty
            ? youtubeExplodeRepository.getPersonalizedTrending(uniqueArtists)
            : youtubeExplodeRepository.getTrending('Music'),
      ]);

      final newReleases = results[0];

      // Priorità 3: filtra i related per durata (esclude shorts e compilazioni)
      // + filtro musicale (artist != null) con fallback se lista diventerebbe vuota
      final newReleasesIds = newReleases.map((v) => v.id).toSet();
      final rawRelated = results[1]
          .where((v) {
            final d = v.duration;
            if (d == null) return true;
            return d >= _discoverMinDuration && d <= _discoverMaxDuration;
          })
          .where((v) => !newReleasesIds.contains(v.id))
          .toList();
      // Preferisci video con tag musicale; fallback all'intera lista filtrata per durata
      final musicalRelated = rawRelated.where((v) => v.artist != null).toList();
      final discoverRelated =
          musicalRelated.isNotEmpty ? musicalRelated : rawRelated;

      emit(MusicTabState.loaded(
        newReleases: newReleases,
        discoverVideo: discoverVideo,
        discoverRelated: discoverRelated,
        trending: results[2],
        isInternationalTrending: !hasFavorites,
      ));
    } catch (e) {
      emit(MusicTabState.error(error: e.toString()));
    }
  }

  /// Recupera gli ultimi upload da ogni canale preferito in parallelo.
  /// Priorità 1:
  /// - esclude shorts (duration <= 60s)
  /// - prende al max 2 video per canale
  /// - cap globale di 20 video totali
  static const _newReleasesMinDuration = Duration(seconds: 61);
  static const _newReleasesMaxPerChannel = 2;
  static const _newReleasesMaxTotal = 20;

  Future<List<VideoTile>> _fetchNewReleases(dynamic favoriteChannels) async {
    if ((favoriteChannels as List).isEmpty) return [];
    final futures = favoriteChannels.map((channel) async {
      try {
        final channelData =
            await youtubeExplodeRepository.getChannel(channel.id);
        final uploads = channelData['videos'] as List<VideoTile>;
        // Filtra per durata (escludi shorts) e preferisci video con tag musicale;
        // fallback all'intera lista filtrata per durata se nessun video ha il tag.
        final durationFiltered = uploads
            .where((v) =>
                v.duration == null || v.duration! > _newReleasesMinDuration)
            .toList();
        final musicalUploads =
            durationFiltered.where((v) => v.artist != null).toList();
        final pool =
            musicalUploads.isNotEmpty ? musicalUploads : durationFiltered;
        return pool.take(_newReleasesMaxPerChannel).toList();
      } catch (_) {
        return <VideoTile>[];
      }
    });
    final nested = await Future.wait(futures);
    return nested.expand((i) => i).take(_newReleasesMaxTotal).toList();
  }
}

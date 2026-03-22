import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/respositories/favorite_repository.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/utils/constants.dart';

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

  final Box _settingsBox = Hive.box(hiveSettingsBoxName);

  Future<void> _onGetMusicTabContent(
      GetMusicTabContent event, Emitter<MusicTabState> emit) async {
    emit(const MusicTabState.loading());
    try {
      // Favorites vengono dal DB locale – veloci, in sequenza
      final favoriteVideos = await favoriteRepository.favoriteVideos;
      final favoriteChannels = await favoriteRepository.favoriteChannels;
      final recentlyPlayed = await favoriteRepository.recentlyPlayed;

      final hasFavorites =
          favoriteVideos.isNotEmpty || favoriteChannels.isNotEmpty;

      // Priorità 2+5: scegli seed Discover preferendo video con tag musicale;
      // l'indice avanza ad ogni apertura (rotazione) invece di essere puramente random.
      VideoTile? discoverVideo;
      if (favoriteVideos.isNotEmpty) {
        final musicSeeds =
            favoriteVideos.where((v) => v.artist != null).toList();
        final pool = musicSeeds.isNotEmpty ? musicSeeds : favoriteVideos;
        final currentIdx = (_settingsBox.get(settingsMusicDiscoverSeedKey,
                defaultValue: 0) as int) %
            pool.length;
        discoverVideo = pool[currentIdx];
        _settingsBox.put(settingsMusicDiscoverSeedKey, currentIdx + 1);
      }

      // Priorità 8: se ci sono artisti tra i preferiti, usa il trending personalizzato
      final uniqueArtists = favoriteVideos
          .map((v) => v.artist)
          .whereType<String>()
          .toSet()
          .toList();

      // Emetti subito con i dati locali già disponibili + flag di caricamento
      // per le sezioni di rete ancora in attesa → la UI si aggiorna immediatamente.
      emit(MusicTabState.loaded(
        recentlyPlayed: recentlyPlayed,
        discoverVideo: discoverVideo,
        isInternationalTrending: !hasFavorites,
        isFeaturedChannelsLoading: uniqueArtists.isNotEmpty,
        isFeaturedPlaylistsLoading: uniqueArtists.isNotEmpty,
        isNewReleasesLoading: favoriteChannels.isNotEmpty,
        isDiscoverLoading: discoverVideo != null,
        isTrendingLoading: true,
      ));

      // Le sezioni di rete partono in parallelo; ognuna emette non appena
      // ha i propri dati, senza aspettare le altre.
      await Future.wait([
        _loadSectionFeaturedChannels(emit, uniqueArtists,
            favoriteRepository.channelIds.toSet()),
        _loadSectionFeaturedPlaylists(emit, uniqueArtists,
            favoriteRepository.playlistIds.toSet()),
        _loadSectionNewReleases(emit, favoriteChannels),
        _loadSectionDiscover(emit, discoverVideo),
        _loadSectionTrending(emit, uniqueArtists, !hasFavorites),
      ]);
    } catch (e) {
      emit(MusicTabState.error(error: e.toString()));
    }
  }

  // ── Section loaders ────────────────────────────────────────────────────────

  Future<void> _loadSectionFeaturedChannels(Emitter<MusicTabState> emit,
      List<String> artistNames, Set<String> favoriteChannelIds) async {
    if (artistNames.isEmpty) {
      emit(state.copyWith(isFeaturedChannelsLoading: false));
      return;
    }
    try {
      final channels = await youtubeExplodeRepository.getFeaturedChannels(
          artistNames, favoriteChannelIds);
      emit(state.copyWith(
        featuredChannels: channels,
        isFeaturedChannelsLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isFeaturedChannelsLoading: false));
    }
  }

  Future<void> _loadSectionFeaturedPlaylists(Emitter<MusicTabState> emit,
      List<String> artistNames, Set<String> favoritePlaylistIds) async {
    if (artistNames.isEmpty) {
      emit(state.copyWith(isFeaturedPlaylistsLoading: false));
      return;
    }
    try {
      final playlists = await youtubeExplodeRepository.getFeaturedPlaylists(
          artistNames, favoritePlaylistIds);
      emit(state.copyWith(
        featuredPlaylists: playlists,
        isFeaturedPlaylistsLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isFeaturedPlaylistsLoading: false));
    }
  }

  Future<void> _loadSectionNewReleases(
      Emitter<MusicTabState> emit, List<ChannelTile> favoriteChannels) async {
    if (favoriteChannels.isEmpty) return;
    try {
      final newReleases = await _fetchNewReleases(favoriteChannels);
      emit(state.copyWith(
        newReleases: newReleases,
        isNewReleasesLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isNewReleasesLoading: false));
    }
  }

  Future<void> _loadSectionDiscover(
      Emitter<MusicTabState> emit, VideoTile? seed) async {
    if (seed == null) {
      emit(state.copyWith(isDiscoverLoading: false));
      return;
    }
    try {
      final rawRelated =
          await youtubeExplodeRepository.getRelatedVideos(seed.id);
      // Filtro durata (esclude shorts e compilazioni)
      final durationFiltered = rawRelated.where((v) {
        final d = v.duration;
        if (d == null) return true;
        return d >= discoverMinDuration && d <= discoverMaxDuration;
      }).toList();
      // Preferisci video con tag musicale; fallback all'intera lista filtrata
      final musical = durationFiltered.where((v) => v.artist != null).toList();
      final discoverRelated = musical.isNotEmpty ? musical : durationFiltered;
      emit(state.copyWith(
        discoverRelated: discoverRelated,
        isDiscoverLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isDiscoverLoading: false));
    }
  }

  Future<void> _loadSectionTrending(Emitter<MusicTabState> emit,
      List<String> uniqueArtists, bool isInternational) async {
    final countryCode = _settingsBox.get(settingsCountryCodeKey,
        defaultValue: defaultCountryCode) as String;
    try {
      final trending = uniqueArtists.isNotEmpty
          ? await youtubeExplodeRepository
              .getPersonalizedTrending(uniqueArtists, countryCode: countryCode)
          : await youtubeExplodeRepository.getTrending('Music',
              countryCode: countryCode);
      emit(state.copyWith(
        trending: trending,
        isTrendingLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isTrendingLoading: false));
    }
  }

  /// Recupera gli ultimi upload da ogni canale preferito in parallelo.
  /// Priorità 1:
  /// - esclude shorts (duration <= 60s)
  /// - prende al max 2 video per canale
  /// - cap globale di 20 video totali

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
                v.duration == null || v.duration! > newReleasesMinDuration)
            .toList();
        final musicalUploads =
            durationFiltered.where((v) => v.artist != null).toList();
        final pool =
            musicalUploads.isNotEmpty ? musicalUploads : durationFiltered;
        return pool.take(newReleasesMaxPerChannel).toList();
      } catch (_) {
        return <VideoTile>[];
      }
    });
    final nested = await Future.wait(futures);
    return nested.expand((i) => i).take(newReleasesMaxTotal).toList();
  }
}

import 'dart:developer';

import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/utils/app_cache.dart';
import 'package:my_tube/utils/constants.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:my_tube/providers/youtube_explode_provider.dart';

class YoutubeExplodeRepository {
  YoutubeExplodeRepository({required this.youtubeExplodeProvider});

  final YoutubeExplodeProvider youtubeExplodeProvider;

  // Cache per i metadata dei video con TTL di 24 ore
  final _videoCache = AppCache<Video>(ttl: Duration(hours: 24));

  // Cache per i trending con TTL di 1 ora
  final _trendingCache = AppCache<List<VideoTile>>(ttl: Duration(hours: 1));

  // Cache per gli stream URL con TTL di 1 ora.
  // Gli URL CDN di YouTube sono validi ~6 ore; 1 ora è un buon compromesso
  // tra freschezza e riduzione delle chiamate di rete.
  final _streamUrlCache = AppCache<String>(ttl: Duration(hours: 1));

  /// Recupera un oggetto [Video] raw dalla cache o dalla rete.
  Future<Video> getCachedVideo(String id) async {
    final cached = _videoCache.get(id);
    if (cached != null) {
      log('Video $id recuperato dalla cache');
      return cached;
    }

    final video = await youtubeExplodeProvider.getVideo(id);
    _videoCache.set(id, video);
    return video;
  }

  /// Recupera lo stream URL dalla cache o dalla rete.
  Future<String> getCachedStreamUrl(String id) async {
    final cached = _streamUrlCache.get(id);
    if (cached != null) {
      log('Stream URL $id recuperato dalla cache');
      return cached;
    }

    final manifest = await youtubeExplodeProvider.getVideoStreamManifest(id);
    final url = manifest.muxed.isNotEmpty
        ? manifest.muxed.withHighestBitrate().url.toString()
        : manifest.audioOnly.withHighestBitrate().url.toString();
    _streamUrlCache.set(id, url);
    return url;
  }

  Future<VideoTile> getVideoMetadata(String id) async {
    final video = await getCachedVideo(id);
    return VideoTile.fromVideo(video);
  }

  Future<List<VideoTile>> getRelatedVideos(String id) async {
    final video = await getCachedVideo(id);
    final relatedVideos = await youtubeExplodeProvider.getRelatedVideos(video);
    return relatedVideos.map((v) => VideoTile.fromVideo(v)).toList();
  }

  Future<ChannelTile> getChannelMetadata(String id) async {
    final channel = await youtubeExplodeProvider.getChannel(id);
    return ChannelTile.fromChannel(channel);
  }

  Future<PlaylistTile> getPlaylistMetadata(String id) async {
    final playlistFuture = youtubeExplodeProvider.getPlaylist(id);
    final thumbnailFuture = youtubeExplodeProvider.getPlaylistThumbnailUrl(id);

    final playlist = await playlistFuture;
    String thumbnailUrl = playlist.thumbnails.highResUrl;

    try {
      final scrapedThumbnail = await thumbnailFuture;
      if (scrapedThumbnail != null) {
        thumbnailUrl = scrapedThumbnail;
      }
    } catch (_) {
      // Ignore errors, keep default thumbnail
    }

    return PlaylistTile(
      id: playlist.id.value,
      title: playlist.title,
      author: playlist.author,
      thumbnailUrl: thumbnailUrl,
      videoCount: playlist.videoCount,
    );
  }

  /// Simula getTrending usando ricerche predefinite, localizzate per [countryCode].
  Future<List<VideoTile>> getTrending(String trendingCategory,
      {String countryCode = defaultCountryCode}) async {
    try {
      log('getTrending chiamato con categoria: $trendingCategory, paese: $countryCode');

      final cacheKey = '${trendingCategory.toLowerCase()}_$countryCode';
      final cached = _trendingCache.get(cacheKey);
      if (cached != null) {
        log('getTrending: ${cached.length} video per "$trendingCategory" ($countryCode) dalla cache');
        return cached;
      }

      final videos = await youtubeExplodeProvider
          .getTrendingSimulated(trendingCategory, countryCode: countryCode);
      final tiles = videos.map((video) => VideoTile.fromVideo(video)).toList();
      _trendingCache.set(cacheKey, tiles);
      log('getTrending completato, ${tiles.length} video per categoria: $trendingCategory ($countryCode)');
      return tiles;
    } catch (e) {
      log('Errore durante il recupero dei trending video: $e');
      rethrow;
    }
  }

  /// Mood-specific search: wider duration bounds (1 min–15 min), 5 queries per mood.
  Future<List<VideoTile>> getMoodMusic(String mood,
      {String countryCode = defaultCountryCode}) async {
    try {
      log('getMoodMusic: mood=$mood, paese=$countryCode');
      final cacheKey = 'mood_${mood.toLowerCase()}_$countryCode';
      final cached = _trendingCache.get(cacheKey);
      if (cached != null) {
        log('getMoodMusic: ${cached.length} video per "$mood" dalla cache');
        return cached;
      }
      final videos = await youtubeExplodeProvider.getMoodMusicSimulated(mood,
          countryCode: countryCode);
      final tiles = videos.map((video) => VideoTile.fromVideo(video)).toList();
      _trendingCache.set(cacheKey, tiles);
      log('getMoodMusic completato, ${tiles.length} video per mood: $mood');
      return tiles;
    } catch (e) {
      log('Errore getMoodMusic: $e');
      rethrow;
    }
  }

  /// Priorità 8: trending personalizzato basato sugli artisti dei preferiti.
  /// La cache key è deterministica (artisti ordinati + paese) con TTL 1 ora.
  Future<List<VideoTile>> getPersonalizedTrending(List<String> artists,
      {String countryCode = defaultCountryCode}) async {
    try {
      final sortedArtists = List<String>.from(artists)..sort();
      final cacheKey =
          'personalized_${sortedArtists.take(3).join(',')}_$countryCode';

      final cached = _trendingCache.get(cacheKey);
      if (cached != null) {
        log('getPersonalizedTrending: ${cached.length} video dalla cache');
        return cached;
      }

      final videos = await youtubeExplodeProvider
          .getPersonalizedTrendingFromArtists(artists,
              countryCode: countryCode);
      final tiles = videos.map((v) => VideoTile.fromVideo(v)).toList();
      _trendingCache.set(cacheKey, tiles);
      log('getPersonalizedTrending completato, ${tiles.length} video ($countryCode)');
      return tiles;
    } catch (e) {
      log('Errore durante il recupero del trending personalizzato: $e');
      rethrow;
    }
  }

  Future<List<Video>> getPlaylistVideos(String playlistId) async {
    return await youtubeExplodeProvider.getPlaylistVideos(playlistId);
  }

  Future<Map<String, dynamic>> getPlaylist(String playlistId) async {
    try {
      final playlistMetadataFuture =
          youtubeExplodeProvider.getPlaylist(playlistId);
      final videosFuture = youtubeExplodeProvider.getPlaylistVideos(playlistId);
      final thumbnailFuture =
          youtubeExplodeProvider.getPlaylistThumbnailUrl(playlistId);

      final results = await Future.wait([
        playlistMetadataFuture,
        videosFuture,
        thumbnailFuture,
      ]);

      final playlistMetadata = results[0] as Playlist;
      final videos = results[1] as List<Video>;
      final thumbnailUrl = results[2] as String?;

      final videoTiles =
          videos.map((video) => VideoTile.fromVideo(video)).toList();

      return {
        'playlist': playlistMetadata,
        'videos': videoTiles,
        'thumbnailUrl': thumbnailUrl ?? playlistMetadata.thumbnails.highResUrl,
      };
    } catch (e) {
      log('Errore durante il recupero della playlist: $e');
      rethrow;
    }
  }

  /// Recupera suggerimenti di ricerca
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final suggestions =
          await youtubeExplodeProvider.getSearchSuggestions(query);
      return suggestions;
    } catch (e) {
      log('Errore durante il recupero dei suggerimenti di ricerca: $e');
      return [];
    }
  }

  /// Ricerca contenuti unificata (video, canali, playlist)
  /// Ricerca contenuti unificata (video, canali, playlist).
  ///
  /// Restituisce una mappa con due chiavi:
  /// - 'items': la lista di tiles convertite
  /// - 'searchList': l'oggetto [SearchList] restituito dalla libreria
  ///
  /// Lo [SearchList] può essere usato successivamente per richiedere
  /// altre pagine tramite [nextSearchContents].
  Future<Map<String, dynamic>> searchContents({required String query}) async {
    try {
      final searchResults = await youtubeExplodeProvider.searchContent(query);
      final videos = <VideoTile>[];
      final channels = <ChannelTile>[];
      final playlists = <PlaylistTile>[];

      for (final result in searchResults) {
        if (result is SearchVideo) {
          videos.add(VideoTile.fromSearchVideo(result));
        } else if (result is SearchChannel) {
          channels.add(ChannelTile.fromSearchChannel(result));
        } else if (result is SearchPlaylist && result.videoCount > 0) {
          playlists.add(PlaylistTile.fromSearchPlaylist(result));
        }
      }

      return {
        'items': [...channels, ...videos, ...playlists],
        'searchList': searchResults,
      };
    } catch (e) {
      log('Errore durante la ricerca dei contenuti: $e');
      rethrow;
    }
  }

  /// Richiede la pagina successiva a partire dallo [SearchList] fornito.
  /// Restituisce `null` se non ci sono più risultati.
  Future<List<dynamic>?> nextSearchContents(SearchList searchList) async {
    try {
      final nextPage =
          await youtubeExplodeProvider.getNextSearchContent(searchList);
      if (nextPage == null) return null;

      final videos = <VideoTile>[];
      final channels = <ChannelTile>[];
      final playlists = <PlaylistTile>[];

      for (final result in nextPage) {
        if (result is SearchVideo) {
          videos.add(VideoTile.fromSearchVideo(result));
        } else if (result is SearchChannel) {
          channels.add(ChannelTile.fromSearchChannel(result));
        } else if (result is SearchPlaylist) {
          playlists.add(PlaylistTile.fromSearchPlaylist(result));
        }
      }

      return [...videos, ...channels, ...playlists];
    } catch (e) {
      log('Errore durante il recupero della pagina successiva: $e');
      rethrow;
    }
  }

  /// Recupera canali consigliati basandosi sui nomi degli artisti preferiti.
  /// Prende al massimo 1 canale per artista (il top result, cioè il più
  /// rilevante), esclude i canali già nelle preferenze ([excludeIds]).
  Future<List<ChannelTile>> getFeaturedChannels(
      List<String> artistNames, Set<String> excludeIds) async {
    if (artistNames.isEmpty) return [];
    final seenIds = <String>{...excludeIds};
    final artistsToSearch = artistNames.take(featuredChannelsMaxTotal).toList();

    // Ricerca in parallelo per tutti gli artisti
    final searchResults = await Future.wait(
      artistsToSearch.map((artist) async {
        try {
          return await youtubeExplodeProvider.searchChannels('$artist music');
        } catch (e) {
          log('Errore ricerca canali per artista "$artist": $e');
          return <SearchChannel>[];
        }
      }),
    );

    final results = <ChannelTile>[];
    for (int i = 0; i < artistsToSearch.length; i++) {
      if (results.length >= featuredChannelsMaxTotal) break;
      final channels = searchResults[i];
      // Prende solo il primo risultato (top = più rilevante/ufficiale)
      // che non sia già nei preferiti né già selezionato
      final candidates = channels.where((ch) => !seenIds.contains(ch.id.value));
      if (candidates.isNotEmpty) {
        final top = candidates.first;
        seenIds.add(top.id.value);
        results.add(ChannelTile.fromSearchChannel(top));
      }
    }
    return results;
  }

  /// Recupera playlist consigliate basandosi sui nomi degli artisti preferiti.
  /// Prende al massimo 1 playlist per artista (il top result, cioè il più
  /// rilevante), esclude le playlist già nelle preferenze ([excludeIds])
  /// e quelle senza video (videoCount == 0 o null).
  Future<List<PlaylistTile>> getFeaturedPlaylists(
      List<String> artistNames, Set<String> excludeIds) async {
    if (artistNames.isEmpty) return [];
    final seenIds = <String>{...excludeIds};
    final artistsToSearch =
        artistNames.take(featuredPlaylistsMaxTotal).toList();

    // Ricerca in parallelo per tutti gli artisti
    final searchResults = await Future.wait(
      artistsToSearch.map((artist) async {
        try {
          return await youtubeExplodeProvider.searchContent('$artist playlist');
        } catch (e) {
          log('Errore ricerca playlist per artista "$artist": $e');
          return <dynamic>[];
        }
      }),
    );

    final results = <PlaylistTile>[];
    for (int i = 0; i < artistsToSearch.length; i++) {
      if (results.length >= featuredPlaylistsMaxTotal) break;
      final searchItems = searchResults[i];
      // Filtra: esclude playlist già nei preferiti e quelle senza video
      final playlists = searchItems.whereType<SearchPlaylist>();
      final candidates = playlists
          .where((p) => !seenIds.contains(p.id.value) && p.videoCount > 0);
      if (candidates.isNotEmpty) {
        final top = candidates.first;
        seenIds.add(top.id.value);
        results.add(PlaylistTile.fromSearchPlaylist(top));
      }
    }
    return results;
  }

  /// Recupera informazioni di un canale
  Future<Map<String, dynamic>> getChannel(String channelId) async {
    try {
      final channel = await youtubeExplodeProvider.getChannelPage(channelId);

      // getUploadsFromPage fallisce su canali con layout non standard
      // (FatalFailureException). In quel caso si usa il fallback stream-based.
      List<Video> uploadVideos;
      ChannelUploadsList? uploadsListObj;
      try {
        final ul = await youtubeExplodeProvider.getChannelVideos(channelId);
        uploadsListObj = ul;
        uploadVideos = ul;
      } catch (e) {
        log('getChannelVideos fallito per $channelId, uso fallback stream: $e');
        uploadVideos =
            await youtubeExplodeProvider.getChannelVideosFallback(channelId);
      }

      final videoTiles =
          uploadVideos.map((video) => VideoTile.fromVideo(video)).toList();

      // uploadsList è null quando si usa il fallback (nessuna paginazione).
      return {
        'channel': channel,
        'videos': videoTiles,
        'uploadsList': uploadsListObj,
      };
    } catch (e) {
      log('Errore durante il recupero del canale: $e');
      rethrow;
    }
  }

  /// Recupera gli short di un canale
  Future<Map<String, dynamic>> getChannelShorts(String channelId) async {
    try {
      final uploads = await youtubeExplodeProvider.getChannelShorts(channelId);
      final videoTiles =
          uploads.map((video) => VideoTile.fromVideo(video)).toList();
      return {
        'shorts': videoTiles,
        'shortsList': uploads,
      };
    } catch (e) {
      log('Errore durante il recupero degli short del canale: $e');
      rethrow;
    }
  }

  /// Recupera la pagina successiva di short del canale.
  /// Restituisce la nuova [ChannelUploadsList] per consentire ulteriore paginazione.
  Future<ChannelUploadsList?> nextChannelShorts(
      ChannelUploadsList uploads) async {
    try {
      return await youtubeExplodeProvider.getNextChannelVideos(uploads);
    } catch (e) {
      log('Errore durante il recupero degli short successivi del canale: $e');
      rethrow;
    }
  }

  /// Recupera le playlist di un canale tramite ricerca per titolo
  Future<Map<String, dynamic>> getChannelPlaylists(String channelTitle) async {
    try {
      final searchList =
          await youtubeExplodeProvider.getChannelPlaylists(channelTitle);
      final playlists = searchList
          .whereType<SearchPlaylist>()
          .map((p) => PlaylistTile.fromSearchPlaylist(p))
          .toList();
      return {
        'playlists': playlists,
        'playlistsList': searchList,
      };
    } catch (e) {
      log('Errore durante il recupero delle playlist del canale: $e');
      rethrow;
    }
  }

  /// Recupera la pagina successiva di playlist del canale
  Future<List<PlaylistTile>?> nextChannelPlaylists(
      SearchList searchList) async {
    try {
      final next =
          await youtubeExplodeProvider.getNextChannelPlaylists(searchList);
      if (next == null) return null;
      return next
          .whereType<SearchPlaylist>()
          .map((p) => PlaylistTile.fromSearchPlaylist(p))
          .toList();
    } catch (e) {
      log('Errore durante il recupero delle playlist successive del canale: $e');
      rethrow;
    }
  }

  /// Richiede la pagina successiva di upload a partire da [ChannelUploadsList]
  /// Restituisce `null` se non ci sono più risultati.
  Future<List<Video>?> nextChannelVideos(ChannelUploadsList uploads) async {
    try {
      final next = await youtubeExplodeProvider.getNextChannelVideos(uploads);
      return next?.toList();
    } catch (e) {
      log('Errore durante il recupero della pagina successiva del canale: $e');
      rethrow;
    }
  }
}

import 'dart:developer';

import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/utils/app_cache.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:my_tube/providers/youtube_explode_provider.dart';

class YoutubeExplodeRepository {
  YoutubeExplodeRepository({required this.youtubeExplodeProvider});

  final YoutubeExplodeProvider youtubeExplodeProvider;

  // Cache per i metadata dei video con TTL di 1 ora
  final _videoCache = AppCache<Video>(ttl: Duration(hours: 1));

  // Cache per i trending con TTL di 30 minuti
  final _trendingCache = AppCache<List<VideoTile>>(ttl: Duration(minutes: 30));

  /// Recupera un video dalla cache o dalla rete
  Future<Video> _getCachedVideo(String id) async {
    final cached = _videoCache.get(id);
    if (cached != null) {
      log('Video $id recuperato dalla cache');
      return cached;
    }

    final video = await youtubeExplodeProvider.getVideo(id);
    _videoCache.set(id, video);
    return video;
  }

  Future<VideoTile> getVideoMetadata(String id) async {
    final video = await _getCachedVideo(id);
    return VideoTile.fromVideo(video);
  }

  Future<List<VideoTile>> getRelatedVideos(String id) async {
    final video = await _getCachedVideo(id);
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

  /// Simula getTrending usando ricerche predefinite
  Future<List<VideoTile>> getTrending(String trendingCategory) async {
    try {
      log('getTrending chiamato con categoria: $trendingCategory');

      final cacheKey = trendingCategory.toLowerCase();
      final cached = _trendingCache.get(cacheKey);
      if (cached != null) {
        log('getTrending: ${cached.length} video per "$trendingCategory" dalla cache');
        return cached;
      }

      final videos =
          await youtubeExplodeProvider.getTrendingSimulated(trendingCategory);
      final tiles = videos.map((video) => VideoTile.fromVideo(video)).toList();
      _trendingCache.set(cacheKey, tiles);
      log('getTrending completato, ${tiles.length} video trovati per categoria: $trendingCategory');
      return tiles;
    } catch (e) {
      log('Errore durante il recupero dei trending video: $e');
      rethrow;
    }
  }

  /// Priorità 8: trending personalizzato basato sugli artisti dei preferiti.
  /// La cache key è deterministica (artisti ordinati) con TTL 30 min.
  Future<List<VideoTile>> getPersonalizedTrending(List<String> artists) async {
    try {
      final sortedArtists = List<String>.from(artists)..sort();
      final cacheKey = 'personalized_${sortedArtists.take(3).join(',')}';

      final cached = _trendingCache.get(cacheKey);
      if (cached != null) {
        log('getPersonalizedTrending: ${cached.length} video dalla cache');
        return cached;
      }

      final videos = await youtubeExplodeProvider
          .getPersonalizedTrendingFromArtists(artists);
      final tiles = videos.map((v) => VideoTile.fromVideo(v)).toList();
      _trendingCache.set(cacheKey, tiles);
      log('getPersonalizedTrending completato, ${tiles.length} video');
      return tiles;
    } catch (e) {
      log('Errore durante il recupero del trending personalizzato: $e');
      rethrow;
    }
  }

  /// Simula getMusicHome usando ricerche musicali predefinite
  /* Future<MusicHomeMT> getMusicHome() async {
    try {
      final videos = await youtubeExplodeProvider.getMusicHomeSimulated();

      // Dividi i video in sezioni simulate
      final carouselVideos = videos.take(5).toList();
      final topMusic = videos.skip(5).take(10).toList();
      final newReleases = videos.skip(15).take(10).toList();

      final carouselResources = await Future.wait(
          carouselVideos.map((video) => getResourceMTFromVideo(video)));

      final sections = <SectionMT>[];

      if (topMusic.isNotEmpty) {
        final topMusicResources = await Future.wait(
            topMusic.map((video) => getResourceMTFromVideo(video)));
        sections.add(SectionMT(
          title: 'Top Music',
          playlistId: null,
          videos: topMusicResources,
          playlists: [],
        ));
      }

      if (newReleases.isNotEmpty) {
        final newReleasesResources = await Future.wait(
            newReleases.map((video) => getResourceMTFromVideo(video)));
        sections.add(SectionMT(
          title: 'New Releases',
          playlistId: null,
          videos: newReleasesResources,
          playlists: [],
        ));
      }

      return MusicHomeMT(
        title: 'Music',
        description: 'Discover new music',
        carouselVideos: carouselResources,
        sections: sections,
      );
    } catch (e) {
      log('Errore durante il recupero della home music: $e');
      rethrow;
    }
  } */

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

  /// Recupera informazioni di un canale
  Future<Map<String, dynamic>> getChannel(String channelId) async {
    try {
      final channelPageFuture =
          youtubeExplodeProvider.getChannelPage(channelId);
      final channelVideosFuture =
          youtubeExplodeProvider.getChannelVideos(channelId);
      final results =
          await Future.wait([channelPageFuture, channelVideosFuture]);
      final channel = results[0] as Channel;
      final uploads = results[1] as List<Video>;
      final videoTiles =
          uploads.map((video) => VideoTile.fromVideo(video)).toList();

      // Ritorniamo anche l'oggetto uploads (ChannelUploadsList) per permettere
      // il caricamento di pagine successive.
      return {
        'channel': channel,
        'videos': videoTiles,
        'uploadsList': uploads,
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

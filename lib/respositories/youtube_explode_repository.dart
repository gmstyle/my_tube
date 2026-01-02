import 'dart:developer';

import 'package:my_tube/models/tiles.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:my_tube/providers/youtube_explode_provider.dart';

class YoutubeExplodeRepository {
  YoutubeExplodeRepository({required this.youtubeExplodeProvider});

  final YoutubeExplodeProvider youtubeExplodeProvider;

  // Cache per i metadata dei video con TTL di 1 ora
  final Map<String, ({Video video, DateTime timestamp})> _videoCache = {};
  static const Duration _cacheTTL = Duration(hours: 1);

  // Removed unused _normalizeUrl helper (was unused and triggered analyzer warning)

  /// Recupera un video dalla cache o dalla rete
  Future<Video> _getCachedVideo(String id) async {
    final cached = _videoCache[id];
    final now = DateTime.now();

    // Se il video è in cache e non è scaduto, ritornalo
    if (cached != null && now.difference(cached.timestamp) < _cacheTTL) {
      log('Video $id recuperato dalla cache');
      return cached.video;
    }

    // Altrimenti scaricalo e salvalo in cache
    log('Video $id scaricato dalla rete');
    final video = await youtubeExplodeProvider.getVideo(id);
    _videoCache[id] = (video: video, timestamp: now);

    // Pulizia cache: rimuovi entry scadute (max 500 entry per evitare memory leak)
    if (_videoCache.length > 500) {
      _videoCache.removeWhere(
        (key, value) => now.difference(value.timestamp) >= _cacheTTL,
      );
    }

    return video;
  }

  Future<VideoTile> getVideoMetadata(String id) async {
    final video = await _getCachedVideo(id);
    return VideoTile.fromVideo(video);
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
      // Passa direttamente la categoria al provider senza ulteriore mapping
      final videos =
          await youtubeExplodeProvider.getTrendingSimulated(trendingCategory);
      log('getTrending completato, ${videos.length} video trovati per categoria: $trendingCategory');
      return videos.map((video) => VideoTile.fromVideo(video)).toList();
    } catch (e) {
      log('Errore durante il recupero dei trending video: $e');
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
      final channel = await youtubeExplodeProvider.getChannelPage(channelId);
      final uploads = await youtubeExplodeProvider.getChannelVideos(channelId);
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

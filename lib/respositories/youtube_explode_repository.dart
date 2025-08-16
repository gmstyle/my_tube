import 'dart:developer';

import 'package:my_tube/models/tiles.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:my_tube/providers/youtube_explode_provider.dart';

class YoutubeExplodeRepository {
  YoutubeExplodeRepository({required this.youtubeExplodeProvider});

  final YoutubeExplodeProvider youtubeExplodeProvider;

  /// Normalizza l'URL rimuovendo doppi protocolli
  String? _normalizeUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // Rimuovi doppi protocolli come "https:https://"
    if (url.startsWith('https:https://')) {
      return url.substring(6); // Rimuovi il primo "https:"
    }
    if (url.startsWith('http:http://')) {
      return url.substring(5); // Rimuovi il primo "http:"
    }

    return url;
  }

  Future<VideoTile> getVideoMetadata(String id) async {
    final video = await youtubeExplodeProvider.getVideo(id);
    return VideoTile.fromVideo(video);
  }

  Future<ChannelTile> getChannelMetadata(String id) async {
    final channel = await youtubeExplodeProvider.getChannel(id);
    return ChannelTile.fromChannel(channel);
  }

  Future<PlaylistTile> getPlaylistMetadata(String id) async {
    final playlist = await youtubeExplodeProvider.getPlaylist(id);
    return PlaylistTile.fromPlaylist(playlist);
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

  /// Recupera una playlist
  Future<Map<String, dynamic>> getPlaylist(String playlistId) async {
    try {
      final playlistMetadata =
          await youtubeExplodeProvider.getPlaylist(playlistId);

      final videos = await youtubeExplodeProvider.getPlaylistVideos(playlistId);
      final videoTiles =
          videos.map((video) => VideoTile.fromVideo(video)).toList();

      return {
        'playlist': playlistMetadata,
        'videos': videoTiles,
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
  Future<List<dynamic>> searchContents({required String query}) async {
    try {
      // Usa il nuovo metodo unificato di ricerca
      final searchResults = await youtubeExplodeProvider.searchContent(query);
      final videos = <VideoTile>[];
      final channels = <ChannelTile>[];
      final playlists = <PlaylistTile>[];

      for (final result in searchResults) {
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
      log('Errore durante la ricerca dei contenuti: $e');
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

      return {
        'channel': channel,
        'videos': videoTiles,
      };
    } catch (e) {
      log('Errore durante il recupero del canale: $e');
      rethrow;
    }
  }
}

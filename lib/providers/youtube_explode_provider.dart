import 'dart:developer';

import 'package:hive_ce/hive.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeExplodeProvider {
  final settingsBox = Hive.box('settings');
  late final YoutubeExplode _yt;

  YoutubeExplodeProvider() {
    _yt = YoutubeExplode();
  }

  Future<Video> getVideo(String videoId) async {
    final video = await _yt.videos.get(videoId);
    return video;
  }

  Future<Channel> getChannel(String channelId) async {
    final channel = await _yt.channels.get(channelId);
    return channel;
  }

  Future<Playlist> getPlaylist(String playlistId) async {
    final playlist = await _yt.playlists.get(playlistId);
    return playlist;
  }

  Future<List<Video>> getPlaylistVideos(String playlistId) async {
    final videos = <Video>[];
    await for (final video in _yt.playlists.getVideos(playlistId)) {
      videos.add(video);
    }
    return videos;
  }

  Future<SearchList> searchContent(String query) async {
    final searchResult = await _yt.search.searchContent(query);
    return searchResult;
  }

  Future<Channel> getChannelPage(String channelId) async {
    final channel = await _yt.channels.get(channelId);
    return channel;
  }

  Future<ChannelUploadsList> getChannelVideos(String channelId) async {
    final uploads = await _yt.channels.getUploadsFromPage(channelId);
    return uploads;
  }

  Future<ChannelUploadsList?> getNextChannelVideos(
      ChannelUploadsList uploads) async {
    return uploads.nextPage();
  }

  Future<List<dynamic>?> getNextSearchContent(SearchList searchList) async {
    final nextPage = await searchList.nextPage();
    return nextPage;
  }

  Future<StreamManifest> getVideoStreamManifest(String videoId) async {
    final manifest = await _yt.videos.streams.getManifest(videoId,
        ytClients: [YoutubeApiClient.androidVr, YoutubeApiClient.ios]);
    return manifest;
  }

  Future<List<Video>> getTrendingSimulated(String category) async {
    // Simuliamo i trending con ricerche predefinite per categoria
    final queries = _getTrendingQueries(category);
    final results = <Video>[];

    for (final query in queries) {
      try {
        final searchResult =
            await _yt.search.search(query, filter: TypeFilters.video);
        final videos = searchResult.toList();
        results.addAll(videos);
      } catch (e) {
        // Log l'errore ma continua con le altre ricerche
        log('Errore ricerca per "$query": $e');
        continue;
      }
    }

    // Rimuovi duplicati basati sull'ID
    final uniqueResults = <Video>[];
    final seenIds = <String>{};

    for (final video in results) {
      final videoId = video.id.value;
      if (videoId.isNotEmpty && !seenIds.contains(videoId)) {
        seenIds.add(videoId);
        uniqueResults.add(video);
      }
    }

    return uniqueResults;
  }

  Future<List<Video>> getMusicHomeSimulated() async {
    // Simuliamo la music home con query musicali predefinite
    final musicQueries = [
      'top music',
      'new music releases',
      'popular songs',
      'hit songs',
      'music charts',
    ];

    final results = <Video>[];

    for (final query in musicQueries) {
      try {
        final searchResult = await _yt.search.search(query);
        final videos = searchResult.take(8).toList();
        results.addAll(videos);
      } catch (e) {
        continue;
      }
    }

    // Rimuovi duplicati
    final uniqueResults = <Video>[];
    final seenIds = <String>{};

    for (final video in results) {
      final videoId = video.id.value;
      if (videoId.isNotEmpty && !seenIds.contains(videoId)) {
        seenIds.add(videoId);
        uniqueResults.add(video);
      }
    }

    return uniqueResults;
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      // Usiamo l'API nativa di youtube_explode_dart per i suggerimenti
      final suggestions = await _yt.search.getQuerySuggestions(query);
      return suggestions;
    } catch (e) {
      // Fallback ai suggerimenti locali se l'API fallisce
      return _getLocalSearchSuggestions(query);
    }
  }

  List<String> _getTrendingQueries(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return ['trending music', 'top songs', 'new music'];
      case 'gaming':
        return ['gaming', 'gameplay'];
      case 'film':
      case 'movies':
        return ['new movies', 'movie trailers', 'film reviews'];
      case 'now':
      default:
        return ['trending videos', 'popular videos', 'trending today'];
    }
  }

  List<String> _getLocalSearchSuggestions(String query) {
    // Implementazione base con suggerimenti predefiniti
    // Qui si può integrare con cache locale delle ricerche precedenti
    final suggestions = <String>[];

    if (query.isEmpty) return suggestions;

    // Suggerimenti predefiniti basati su categorie comuni
    final predefinedSuggestions = [
      'music',
      'gaming',
      'movies',
      'tutorials',
      'news',
      'comedy',
      'sports',
      'technology',
      'science',
      'education',
    ];

    // Filtra i suggerimenti che iniziano con la query
    for (final suggestion in predefinedSuggestions) {
      if (suggestion.toLowerCase().startsWith(query.toLowerCase())) {
        suggestions.add(suggestion);
      }
    }

    // Aggiungi la query stessa come primo suggerimento se non è vuota
    if (query.length > 2) {
      suggestions.insert(0, query);
    }

    return suggestions.take(10).toList();
  }

  void close() {
    _yt.close();
  }
}

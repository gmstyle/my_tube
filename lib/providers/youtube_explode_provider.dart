import 'package:hive_ce/hive.dart';
import 'package:my_tube/providers/base_provider.dart';
import 'package:my_tube/providers/youtube_provider_interface.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeExplodeProvider extends BaseProvider
    implements YouTubeProviderInterface {
  final settingsBox = Hive.box('settings');
  late final YoutubeExplode _yt;

  YoutubeExplodeProvider() {
    _yt = YoutubeExplode();
  }

  // Getter per accedere al client YoutubeExplode
  YoutubeExplode get client => _yt;

  @override
  Future<Video> getVideo(String videoId, bool? withStreamUrl) async {
    final video = await _yt.videos.get(videoId);
    return video;
  }

  @override
  Future<Playlist> getPlaylist(String playlistId,
      {bool getVideos = true}) async {
    final playlist = await _yt.playlists.get(playlistId);
    return playlist;
  }

  @override
  Future<List<Video>> getPlaylistVideos(String playlistId,
      {int limit = 50}) async {
    final videos = <Video>[];
    await for (final video in _yt.playlists.getVideos(playlistId).take(limit)) {
      videos.add(video);
    }
    return videos;
  }

  @override
  Future<List<Video>> searchVideos(String query, {int limit = 20}) async {
    final searchResult =
        await _yt.search.search(query, filter: TypeFilters.video);
    final videos = <Video>[];

    // Prendi i primi 'limit' video dalla prima pagina
    final firstBatch = searchResult.take(limit > 20 ? 20 : limit).toList();
    videos.addAll(firstBatch);

    // Se servono più video, carica le pagine successive
    if (limit > 20 && videos.length < limit) {
      var currentPage = searchResult;
      while (videos.length < limit) {
        final nextPage = await currentPage.nextPage();
        if (nextPage == null) break;

        final remaining = limit - videos.length;
        final nextBatch = nextPage.take(remaining).toList();
        videos.addAll(nextBatch);
        currentPage = nextPage;
      }
    }

    return videos;
  }

  @override
  Future<List<SearchChannel>> searchChannels(String query,
      {int limit = 10}) async {
    final searchResult =
        await _yt.search.searchContent(query, filter: TypeFilters.channel);
    final channels =
        searchResult.whereType<SearchChannel>().take(limit).toList();
    return channels;
  }

  @override
  Future<List<SearchPlaylist>> searchPlaylists(String query,
      {int limit = 10}) async {
    final searchResult =
        await _yt.search.searchContent(query, filter: TypeFilters.playlist);
    final playlists =
        searchResult.whereType<SearchPlaylist>().take(limit).toList();
    return playlists;
  }

  @override
  Future<Channel> getChannel(String channelId) async {
    final channel = await _yt.channels.get(channelId);
    return channel;
  }

  @override
  Future<List<Video>> getChannelUploads(String channelId,
      {int limit = 50}) async {
    final uploads = <Video>[];
    await for (final video in _yt.channels.getUploads(channelId).take(limit)) {
      uploads.add(video);
    }
    return uploads;
  }

  @override
  Future<StreamManifest> getVideoStreamManifest(String videoId) async {
    final manifest = await _yt.videos.streamsClient
        .getManifest(videoId, ytClients: [YoutubeApiClient.androidVr]);
    return manifest;
  }

  @override
  Future<List<Video>> getTrendingSimulated(String category) async {
    // Simuliamo i trending con ricerche predefinite per categoria
    final queries = _getTrendingQueries(category);
    print('getTrendingSimulated chiamato con categoria: $category');
    print('Query da utilizzare: $queries');
    final results = <Video>[];

    for (int i = 0; i < queries.length; i++) {
      final query = queries[i];
      try {
        // Aggiungi un piccolo delay tra le richieste per evitare rate limiting
        if (i > 0) {
          await Future.delayed(const Duration(milliseconds: 500));
        }

        final searchResult =
            await _yt.search.search(query, filter: TypeFilters.video);
        final videos = searchResult.take(15).toList(); // Più video per query
        results.addAll(videos);
        print('Query "$query" ha restituito ${videos.length} video');
      } catch (e) {
        print('Errore con query "$query": $e');
        // Continua con la prossima query se una fallisce
        continue;
      }
    }

    // Rimuovi duplicati basati sull'ID
    final uniqueResults = <Video>[];
    final seenIds = <String>{};

    for (final video in results) {
      if (!seenIds.contains(video.id.value)) {
        seenIds.add(video.id.value);
        uniqueResults.add(video);
      }
    }

    return uniqueResults.take(50).toList();
  }

  @override
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
        final searchResult =
            await _yt.search.search(query, filter: TypeFilters.video);
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
      if (!seenIds.contains(video.id.value)) {
        seenIds.add(video.id.value);
        uniqueResults.add(video);
      }
    }

    return uniqueResults;
  }

  @override
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
        return ['trending music', 'top songs', 'new music', 'viral songs'];
      case 'gaming':
        return ['gaming', 'gameplay'];
      case 'film':
      case 'movies':
        return ['new movies', 'movie trailers', 'film reviews', 'cinema'];
      case 'now':
      default:
        return [
          'trending now',
          'viral videos',
          'popular videos',
          'trending today'
        ];
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

  @override
  void close() {
    _yt.close();
  }
}

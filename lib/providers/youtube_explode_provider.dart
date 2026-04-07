import 'dart:developer';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;
import 'package:my_tube/utils/constants.dart';

/// Data source puro per youtube_explode_dart.
/// Non gestisce alcuna cache: è responsabilità del Repository.
class YoutubeExplodeProvider {
  late final YoutubeExplode _yt;

  YoutubeExplodeProvider() {
    _yt = YoutubeExplode();
  }

  Future<Video> getVideo(String videoId) async {
    log('Video $videoId scaricato dalla rete');
    return _yt.videos.get(videoId);
  }

  Future<List<Video>> getRelatedVideos(Video video) async {
    final relatedVideos = await _yt.videos.getRelatedVideos(video);
    return relatedVideos?.toList() ?? [];
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

  Future<ChannelUploadsList> getChannelShorts(String channelId) async {
    final uploads = await _yt.channels
        .getUploadsFromPage(channelId, videoType: VideoType.shorts);
    return uploads;
  }

  Future<ChannelUploadsList?> getNextChannelVideos(
      ChannelUploadsList uploads) async {
    return uploads.nextPage();
  }

  /// Fallback per [getChannelVideos]: usa lo stream playlist-based (UU…).
  /// Non supporta paginazione ma è più robusto per canali con layout non standard.
  Future<List<Video>> getChannelVideosFallback(String channelId) async {
    return _yt.channels.getUploads(channelId).take(30).toList();
  }

  /// Cerca le playlist di un canale tramite il titolo del canale.
  /// Non esiste un'API diretta in youtube_explode_dart per le playlist di un canale,
  /// quindi si usa la ricerca filtrata per playlist.
  Future<SearchList> getChannelPlaylists(String channelTitle) async {
    return _yt.search.searchContent(channelTitle, filter: TypeFilters.playlist);
  }

  Future<SearchList?> getNextChannelPlaylists(SearchList searchList) async {
    return searchList.nextPage();
  }

  Future<List<SearchChannel>> searchChannels(String query) async {
    final results =
        await _yt.search.searchContent(query, filter: TypeFilters.channel);
    return results.whereType<SearchChannel>().toList();
  }

  Future<List<dynamic>?> getNextSearchContent(SearchList searchList) async {
    final nextPage = await searchList.nextPage();
    return nextPage;
  }

  Future<StreamManifest> getVideoStreamManifest(String videoId) async {
    final manifest = await _yt.videos.streams.getManifest(videoId,
        ytClients: [
          YoutubeApiClient.androidVr,
          YoutubeApiClient.ios,
          YoutubeApiClient.androidSdkless
        ],
        requireWatchPage: false);
    return manifest;
  }

  /// Deduplica, filtra per durata e ordina (video con tag musicale prima).
  List<Video> _dedupeFilterSort(List<Video> videos) {
    final seenIds = <String>{};
    final unique = videos.where((v) {
      final id = v.id.value;
      if (id.isEmpty || seenIds.contains(id)) return false;
      seenIds.add(id);
      return true;
    }).toList();

    // Priorità 7a: escludi shorts (< 2 min) e compilazioni (> 12 min)
    final filtered = unique.where((v) {
      final d = v.duration;
      if (d == null) return true;
      return d >= trendingMinDuration && d <= trendingMaxDuration;
    }).toList();

    // Priorità 7b: porta in cima i video con tag musicale ufficiale
    filtered.sort((a, b) {
      final aScore = a.musicData.isNotEmpty ? 0 : 1;
      final bScore = b.musicData.isNotEmpty ? 0 : 1;
      return aScore.compareTo(bScore);
    });

    return filtered;
  }

  Future<List<Video>> getTrendingSimulated(String category,
      {String countryCode = defaultCountryCode}) async {
    // Esegui tutte le query in parallelo
    final queries = _getTrendingQueriesLocalized(category, countryCode);
    final searchFutures = queries.map((query) async {
      try {
        final searchResult =
            await _yt.search.search(query, filter: TypeFilters.video);
        return searchResult.toList();
      } catch (e) {
        log('Errore ricerca per "$query": $e');
        return <Video>[];
      }
    });
    final nestedResults = await Future.wait(searchFutures);
    return _dedupeFilterSort(nestedResults.expand((v) => v).toList());
  }

  /// Priorità 8: trending personalizzato basato sugli artisti dei video preferiti.
  /// Usa query del tipo "artist new music" eseguite in parallelo.
  /// Ogni artista contribuisce al massimo [personalizedMaxPerArtist] video per evitare
  /// che un singolo artista domini l'intera sezione.
  Future<List<Video>> getPersonalizedTrendingFromArtists(List<String> artists,
      {String countryCode = defaultCountryCode}) async {
    // Randomizza l'ordine degli artisti per variare i risultati ad ogni refresh
    final shuffled = List<String>.from(artists)..shuffle();
    final suffix = _getNewMusicSuffix(countryCode);
    final queries = shuffled
        .take(personalizedArtistQueryLimit)
        .map((a) => '"$a" $suffix')
        .toList();

    final searchFutures = queries.map((query) async {
      try {
        final result =
            await _yt.search.search(query, filter: TypeFilters.video);
        return result.toList();
      } catch (e) {
        log('Errore ricerca personalizzata per "$query": $e');
        return <Video>[];
      }
    });

    // Interleave: prende i risultati a rotazione tra gli artisti
    // invece di concatenare (query1 + query2 + ...) per bilanciare la presenza.
    final perArtist = await Future.wait(searchFutures);
    final interleaved = <Video>[];
    final maxLen = perArtist.fold(0, (m, l) => l.length > m ? l.length : m);
    for (int i = 0; i < maxLen; i++) {
      for (final list in perArtist) {
        if (i < list.length) interleaved.add(list[i]);
      }
    }

    // Cap per artista: massimo _personalizedMaxPerArtist video per nome artista
    final artistCount = <String, int>{};
    final capped = interleaved.where((v) {
      final artist =
          v.musicData.isNotEmpty ? v.musicData.first.artist ?? '' : v.author;
      final key = artist.toLowerCase();
      final count = artistCount[key] ?? 0;
      if (count >= personalizedMaxPerArtist) return false;
      artistCount[key] = count + 1;
      return true;
    }).toList();

    return _dedupeFilterSort(capped);
  }

  Future<List<Video>> getMusicHomeSimulated() async {
    final results = <Video>[];

    for (final query in musicHomeQueries) {
      try {
        final searchResult = await _yt.search.search(query);
        final videos = searchResult.take(musicHomeMaxVideosPerQuery).toList();
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

  // Query inglesi di fallback per ogni categoria.
  List<String> _getTrendingQueries(String category) {
    return trendingEnglishQueriesByCategory[category.toLowerCase()] ??
        defaultTrendingQueries;
  }

  /// Restituisce query localizzate per [category] in base al [countryCode].
  /// Per paesi non anglofoni combina 2 query nella lingua locale + 1 inglese;
  /// per paesi anglofoni usa le sole query inglesi.
  List<String> _getTrendingQueriesLocalized(
      String category, String countryCode) {
    final langCode = _countryToLangCode(countryCode);
    final localQueries =
        localizedTrendingOverrides[category.toLowerCase()]?[langCode];
    final englishQueries = _getTrendingQueries(category);
    if (langCode == 'en' || localQueries == null) return englishQueries;
    // 2 query locali + 1 query inglese per mantenere copertura globale
    return [...localQueries.take(2), englishQueries.first];
  }

  /// Restituisce la perifrasi "nuova musica" nella lingua del paese.
  String _getNewMusicSuffix(String countryCode) {
    return newMusicSuffixByCountry[countryCode] ?? 'new music';
  }

  /// Converte un country code in language code usando la mappa condivisa in constants.dart.
  static String _countryToLangCode(String countryCode) =>
      countryToLanguage[countryCode] ?? 'en';

  List<String> _getLocalSearchSuggestions(String query) {
    // Implementazione base con suggerimenti predefiniti
    // Qui si può integrare con cache locale delle ricerche precedenti
    final suggestions = <String>[];

    if (query.isEmpty) return suggestions;

    // Suggerimenti predefiniti basati su categorie comuni
    // Filtra i suggerimenti che iniziano con la query
    for (final suggestion in predefinedSearchSuggestions) {
      if (suggestion.toLowerCase().startsWith(query.toLowerCase())) {
        suggestions.add(suggestion);
      }
    }

    // Aggiungi la query stessa come primo suggerimento se non è vuota
    if (query.length > localSuggestionsInsertQueryMinLength) {
      suggestions.insert(0, query);
    }

    return suggestions.take(localSuggestionsMaxResults).toList();
  }

  Future<String?> getPlaylistThumbnailUrl(String playlistId) async {
    try {
      final url =
          Uri.parse('https://www.youtube.com/playlist?list=$playlistId');
      final response = await http.get(url);

      if (response.statusCode != 200) return null;

      // Extract og:image using Regex to avoid heavy html package if possible,
      // but since we want robustness matching Syncara, we can use regex on the string.
      // <meta property="og:image" content="URL">
      final regex = RegExp(r'<meta\s+property="og:image"\s+content="([^"]+)"');
      final match = regex.firstMatch(response.body);

      return match?.group(1);
    } catch (e) {
      log('Error scraping playlist thumbnail: $e');
      return null;
    }
  }

  void close() {
    _yt.close();
  }
}

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

  /// Cerca le playlist di un canale tramite il titolo del canale.
  /// Non esiste un'API diretta in youtube_explode_dart per le playlist di un canale,
  /// quindi si usa la ricerca filtrata per playlist.
  Future<SearchList> getChannelPlaylists(String channelTitle) async {
    return _yt.search.searchContent(channelTitle, filter: TypeFilters.playlist);
  }

  Future<SearchList?> getNextChannelPlaylists(SearchList searchList) async {
    return searchList.nextPage();
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

  // Priorità 7: range di durata accettabile per un singolo musicale
  static const _trendingMinDuration = Duration(minutes: 2);
  static const _trendingMaxDuration = Duration(minutes: 12);

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
      return d >= _trendingMinDuration && d <= _trendingMaxDuration;
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
      {String countryCode = 'US'}) async {
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
  /// Ogni artista contribuisce al massimo [_maxPerArtist] video per evitare
  /// che un singolo artista domini l'intera sezione.
  static const _personalizedMaxPerArtist = 4;

  Future<List<Video>> getPersonalizedTrendingFromArtists(List<String> artists,
      {String countryCode = 'US'}) async {
    // Randomizza l'ordine degli artisti per variare i risultati ad ogni refresh
    final shuffled = List<String>.from(artists)..shuffle();
    final suffix = _getNewMusicSuffix(countryCode);
    final queries = shuffled.take(5).map((a) => '"$a" $suffix').toList();

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
      if (count >= _personalizedMaxPerArtist) return false;
      artistCount[key] = count + 1;
      return true;
    }).toList();

    return _dedupeFilterSort(capped);
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

  // Query inglesi di fallback per ogni categoria.
  List<String> _getTrendingQueries(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return ['trending music', 'top songs', 'new music'];
      case 'pop':
        return ['top pop songs', 'pop music hits', 'best pop music'];
      case 'hip hop':
        return ['hip hop music', 'rap songs', 'hip hop hits'];
      case 'rock':
        return ['rock music', 'rock songs', 'rock hits'];
      case 'r&b soul':
      case 'r&b':
        return ['r&b music', 'soul music', 'rnb songs'];
      case 'electronic':
        return ['electronic music', 'edm songs', 'house music'];
      case 'latin':
        return ['latin music', 'reggaeton hits', 'latin pop'];
      case 'kpop':
        return ['kpop music', 'k-pop hits', 'korean pop songs'];
      case 'jazz':
        return ['jazz music', 'jazz songs', 'best jazz'];
      case 'classical':
        return ['classical music', 'classical songs', 'orchestra music'];
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

  /// Restituisce query localizzate per [category] in base al [countryCode].
  /// Per paesi non anglofoni combina 2 query nella lingua locale + 1 inglese;
  /// per paesi anglofoni usa le sole query inglesi.
  List<String> _getTrendingQueriesLocalized(
      String category, String countryCode) {
    final langCode = _countryToLangCode(countryCode);
    final localQueries =
        _localizedTrendingOverrides[category.toLowerCase()]?[langCode];
    final englishQueries = _getTrendingQueries(category);
    if (langCode == 'en' || localQueries == null) return englishQueries;
    // 2 query locali + 1 query inglese per mantenere copertura globale
    return [...localQueries.take(2), englishQueries.first];
  }

  /// Restituisce la perifrasi "nuova musica" nella lingua del paese.
  String _getNewMusicSuffix(String countryCode) {
    const suffixMap = <String, String>{
      'IT': 'nuova musica',
      'FR': 'nouvelle musique',
      'ES': 'nueva música',
      'MX': 'nueva música',
      'AR': 'nueva música',
      'DE': 'neue musik',
      'AT': 'neue musik',
      'CH': 'neue musik',
      'RU': 'новая музыка',
      'KR': '신곡',
      'BR': 'nova música',
      'PT': 'nova música',
      'CN': '新歌',
      'HK': '新歌',
      'TW': '新歌',
      'TR': 'yeni müzik',
      'ID': 'musik baru',
      'NL': 'nieuwe muziek',
      'BE': 'nieuwe muziek',
      'SE': 'ny musik',
      'DK': 'ny musik',
      'NO': 'ny musikk',
      'PL': 'nowa muzyka',
      'RO': 'muzică nouă',
      'CZ': 'nová hudba',
      'VN': 'nhạc mới',
      'TH': 'เพลงใหม่',
      'FI': 'uusi musiikki',
    };
    return suffixMap[countryCode] ?? 'new music';
  }

  /// Converte un country code in language code usando la mappa condivisa in constants.dart.
  static String _countryToLangCode(String countryCode) =>
      countryToLanguage[countryCode] ?? 'en';

  /// Query locali per categoria e lingua (usate come override delle query inglesi).
  static const Map<String, Map<String, List<String>>>
      _localizedTrendingOverrides = {
    'music': {
      'it': [
        'musica di tendenza',
        'nuova musica italiana',
        'canzoni del momento'
      ],
      'fr': [
        'musique tendance france',
        'nouvelle musique française',
        'hits musique'
      ],
      'es': ['música de moda', 'nueva música', 'canciones populares'],
      'de': ['aktuelle musik', 'neue musik hits', 'musik trends'],
      'ru': ['музыка тренды', 'новая музыка', 'популярные песни'],
      'ja': ['音楽トレンド', '新曲', '人気音楽'],
      'ko': ['최신 음악', '인기 음악', '신곡'],
      'pt': ['música popular', 'novas músicas', 'hits musicais'],
      'zh': ['流行音乐', '新歌', '热门音乐'],
      'hi': ['नई संगीत', 'ट्रेंडिंग संगीत', 'बॉलीवुड हिट्स'],
      'tr': ['müzik trendleri', 'yeni müzik', 'popüler şarkılar'],
      'id': ['musik terbaru', 'lagu populer', 'musik trending'],
      'nl': ['trending muziek', 'nieuwe muziek', 'populaire nummers'],
      'sv': ['trending musik', 'ny musik', 'populär musik'],
      'pl': ['muzyka trendy', 'nowa muzyka', 'popularne piosenki'],
      'ro': ['muzică nouă', 'muzică populară', 'hituri muzicale'],
      'cs': ['hudba trendy', 'nová hudba', 'populární písně'],
      'vi': ['nhạc xu hướng', 'nhạc mới', 'bài hát phổ biến'],
      'th': ['เพลงฮิต', 'เพลงใหม่', 'เพลงไทย'],
      'da': ['trending musik', 'ny musik', 'populær musik'],
      'fi': ['musiikkitrendit', 'uusi musiikki', 'suositut biisit'],
      'nb': ['musikk trending', 'ny musikk', 'populær musikk'],
    },
    'now': {
      'it': ['video di tendenza', 'viral oggi', 'più visti oggi'],
      'fr': ['vidéos tendance', 'viral france', 'plus regardés'],
      'es': ['videos tendencia', 'viral hoy', 'más vistos'],
      'de': ['trending videos', 'viral deutschland', 'meistgesehene videos'],
      'ru': ['трендовые видео', 'вирусное видео', 'популярное сегодня'],
      'ja': ['トレンド動画', 'バイラル動画', '人気動画'],
      'ko': ['트렌드 동영상', '인기 동영상', '바이럴'],
      'pt': ['vídeos tendência', 'viral brasil', 'mais assistidos'],
      'zh': ['热门视频', '病毒视频', '今日热点'],
      'hi': ['ट्रेंडिंग वीडियो', 'वायरल वीडियो', 'आज के वीडियो'],
      'tr': ['trend videolar', 'viral video', 'popüler videolar'],
      'id': ['video trending', 'viral indonesia', 'video populer'],
      'nl': ['trending video\'s', 'virale video\'s', 'populaire video\'s'],
      'sv': ['trending videor', 'virala videor', 'populära videor'],
      'pl': ['trendy wideo', 'wirusowe wideo', 'popularne filmy'],
      'ro': ['videoclipuri trending', 'viral azi', 'cele mai vizionate'],
      'cs': ['trendy videa', 'virální videa', 'populární videa'],
      'vi': ['video xu hướng', 'video viral', 'video phổ biến'],
      'th': ['วิดีโอยอดนิยม', 'วิดีโอไวรัล', 'วิดีโอเทรนด์'],
      'da': ['trending videoer', 'virale videoer', 'populære videoer'],
      'fi': ['trendit videot', 'viraalit videot', 'suositut videot'],
      'nb': ['trending videoer', 'virale videoer', 'populære videoer'],
    },
    'film': {
      'it': ['trailer film', 'cinema italiano', 'nuovi film'],
      'fr': ['bandes annonces', 'cinéma français', 'nouveaux films'],
      'es': ['trailers cine', 'películas nuevas', 'cine español'],
      'de': ['film trailer', 'neue filme', 'kino deutschland'],
      'ru': ['трейлеры фильмов', 'новые фильмы', 'кино 2025'],
      'ja': ['映画予告', '新作映画', '日本映画'],
      'ko': ['영화 예고편', '신작 영화', '한국 영화'],
      'pt': ['trailers filmes', 'novos filmes', 'cinema brasileiro'],
      'zh': ['电影预告片', '新电影', '中国电影'],
      'hi': ['फिल्म ट्रेलर', 'नई बॉलीवुड फिल्में', 'हिंदी फिल्में'],
      'tr': ['film fragmanları', 'yeni filmler', 'sinema türkiye'],
      'id': ['trailer film', 'film terbaru', 'bioskop indonesia'],
      'nl': ['film trailers', 'nieuwe films', 'bioscoop nederland'],
      'sv': ['film trailers', 'nya filmer', 'bio sverige'],
      'pl': ['trailery filmów', 'nowe filmy', 'kino polska'],
      'ro': ['trailer filme', 'filme noi', 'cinema romania'],
      'cs': ['trailery filmů', 'nové filmy', 'kino česko'],
      'vi': ['trailer phim', 'phim mới', 'phim việt nam'],
      'th': ['ตัวอย่างหนัง', 'หนังใหม่', 'ภาพยนตร์ไทย'],
      'da': ['film trailers', 'nye film', 'biograf danmark'],
      'fi': ['elokuva traileri', 'uudet elokuvat', 'elokuva suomi'],
      'nb': ['film trailere', 'nye filmer', 'kino norge'],
    },
    'gaming': {
      'it': ['gaming italiano', 'gameplay ita', 'videogiochi tendenza'],
      'fr': ['gaming france', 'gameplay fr', 'jeux vidéo tendance'],
      'es': ['gaming español', 'gameplay español', 'videojuegos trending'],
      'de': ['gaming deutsch', 'gameplay deutsch', 'spiele trending'],
      'ru': ['игровые видео', 'геймплей', 'игры тренды'],
      'ja': ['ゲーム動画', 'ゲームプレイ', '人気ゲーム'],
      'ko': ['게임 동영상', '게임플레이', '인기 게임'],
      'pt': ['gaming brasil', 'gameplay pt', 'jogos tendência'],
      'zh': ['游戏视频', '游戏直播', '热门游戏'],
      'hi': ['गेमिंग वीडियो', 'गेमप्ले हिंदी', 'वायरल गेम'],
      'tr': ['gaming türkçe', 'gameplay türkiye', 'oyun videoları'],
      'id': ['gaming indonesia', 'gameplay indonesia', 'game populer'],
      'nl': ['gaming nederland', 'gameplay nl', 'populaire games'],
      'sv': ['gaming svenska', 'gameplay svenska', 'populära spel'],
      'pl': ['gaming polska', 'gameplay pl', 'gry trending'],
      'ro': ['gaming romania', 'gameplay ro', 'jocuri trending'],
      'cs': ['gaming česky', 'gameplay cz', 'hry trending'],
      'vi': ['gaming việt nam', 'gameplay vi', 'game phổ biến'],
      'th': ['เกมมิ่งไทย', 'เล่นเกม', 'เกมยอดนิยม'],
      'da': ['gaming dansk', 'gameplay dk', 'populære spil'],
      'fi': ['gaming suomi', 'gameplay fi', 'suositut pelit'],
      'nb': ['gaming norsk', 'gameplay no', 'populære spill'],
    },
  };

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

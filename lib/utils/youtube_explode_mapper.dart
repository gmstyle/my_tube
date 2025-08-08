/// Mapper per convertire i valori di innertube_dart in valori compatibili con youtube_explode_dart
class YouTubeExplodeMapper {
  /// Mappa le categorie trending di innertube_dart in query di ricerca
  static String mapTrendingCategoryToSearchQuery(dynamic trendingCategory) {
    if (trendingCategory == null) return 'trending now';

    final categoryString = trendingCategory.toString().toLowerCase();

    if (categoryString.contains('music')) {
      return 'trending music';
    } else if (categoryString.contains('gaming')) {
      return 'trending gaming';
    } else if (categoryString.contains('film') ||
        categoryString.contains('movie')) {
      return 'trending movies';
    } else if (categoryString.contains('news')) {
      return 'trending news';
    } else {
      return 'trending now';
    }
  }

  /// Mappa le categorie di video per la ricerca
  static List<String> getTrendingQueriesForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return [
          'trending music 2025',
          'top songs 2025',
          'new music releases',
          'viral songs',
          'music hits'
        ];
      case 'gaming':
        return [
          'trending gaming',
          'new games 2025',
          'gameplay highlights',
          'game reviews',
          'gaming news'
        ];
      case 'film':
      case 'movies':
        return [
          'new movies 2025',
          'movie trailers',
          'film reviews',
          'cinema releases',
          'movie news'
        ];
      case 'news':
        return [
          'breaking news',
          'news today',
          'current events',
          'world news',
          'latest news'
        ];
      case 'sports':
        return [
          'sports highlights',
          'latest sports',
          'sports news',
          'game highlights',
          'sports 2025'
        ];
      case 'technology':
        return [
          'tech news',
          'new technology',
          'tech reviews',
          'latest tech',
          'technology 2025'
        ];
      case 'now':
      default:
        return [
          'trending now',
          'viral videos',
          'popular 2025',
          'trending today',
          'most viewed'
        ];
    }
  }

  /// Ottiene query predefinite per la music home
  static List<String> getMusicHomeQueries() {
    return [
      'top music 2025',
      'new music releases',
      'popular songs',
      'hit songs 2025',
      'music charts',
      'trending music',
      'new albums 2025',
      'viral music',
      'pop music 2025',
      'rock music 2025'
    ];
  }

  /// Ottiene query per playlist musicali popolari
  static List<String> getMusicPlaylistQueries() {
    return [
      'best music playlist',
      'top hits playlist',
      'chill music playlist',
      'workout music playlist',
      'study music playlist'
    ];
  }

  /// Converte una Duration in stringa formato "mm:ss" o "h:mm:ss"
  static String? formatDurationToString(Duration? duration) {
    if (duration == null) return null;

    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Parsing di stringa durata in millisecondi (per compatibilità innertube)
  static int? parseDurationToMilliseconds(String? durationString) {
    if (durationString == null || durationString.isEmpty) return null;

    try {
      // Formato: "PT4M33S" or "4:33" or "04:33"
      if (durationString.startsWith('PT')) {
        // ISO 8601 format
        final regex = RegExp(r'PT(?:(\d+)M)?(?:(\d+)S)?');
        final match = regex.firstMatch(durationString);
        if (match != null) {
          final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
          final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
          return (minutes * 60 + seconds) * 1000;
        }
      } else {
        // Format: "4:33" or "1:04:33"
        final parts = durationString.split(':');
        if (parts.length == 2) {
          final minutes = int.tryParse(parts[0]) ?? 0;
          final seconds = int.tryParse(parts[1]) ?? 0;
          return (minutes * 60 + seconds) * 1000;
        } else if (parts.length == 3) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          final seconds = int.tryParse(parts[2]) ?? 0;
          return (hours * 3600 + minutes * 60 + seconds) * 1000;
        }
      }
    } catch (e) {
      // Se il parsing fallisce, ritorna null
      return null;
    }

    return null;
  }

  /// Converte il count dei subscriber in stringa leggibile
  static String? formatSubscriberCount(int? count) {
    if (count == null) return null;

    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  /// Converte il count delle view in stringa leggibile
  static String? formatViewCount(int? count) {
    if (count == null) return null;

    if (count >= 1000000000) {
      return '${(count / 1000000000).toStringAsFixed(1)}B views';
    } else if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M views';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K views';
    } else {
      return '$count views';
    }
  }
}

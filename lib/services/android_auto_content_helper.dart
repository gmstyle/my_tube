import 'package:audio_service/audio_service.dart';
import 'package:my_tube/models/tiles.dart';

/// Helper class per Android Auto content browsing.
/// Gestisce la conversione dei tiles in MediaItem e definisce la struttura di navigazione.
class AndroidAutoContentHelper {
  // ============ ID delle categorie ============
  static const String rootId = '/';

  // Musica
  static const String musicId = 'music';
  static const String musicNewReleasesId = 'music_new_releases';
  static const String musicDiscoverId = 'music_discover';
  static const String musicTrendingId = 'music_trending';

  // Preferiti
  static const String favoritesId = 'favorites';
  static const String favoritesVideosId = 'favorites_videos';
  static const String favoritesChannelsId = 'favorites_channels';
  static const String favoritesPlaylistsId = 'favorites_playlists';

  // Ricerca
  static const String searchId = 'search';

  // Prefissi per navigazione dinamica
  static const String channelPrefix = 'channel_';
  static const String playlistPrefix = 'playlist_';
  static const String searchResultsPrefix = 'search_results_';

  // ============ Categorie Root ============

  /// Restituisce le categorie root per Android Auto
  static List<MediaItem> getRootCategories() {
    return [
      const MediaItem(
        id: musicId,
        title: 'Home',
        playable: false,
        extras: {
          'browsable': true,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 1,
        },
      ),
      const MediaItem(
        id: favoritesId,
        title: 'Favorites',
        playable: false,
        extras: {
          'browsable': true,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 1,
        },
      ),
      const MediaItem(
        id: searchId,
        title: 'Search',
        playable: false,
        extras: {
          'browsable': true,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 1,
        },
      ),
    ];
  }

  /// Restituisce le sottocategorie di Musica
  static List<MediaItem> getMusicCategories() {
    return [
      const MediaItem(
        id: musicNewReleasesId,
        title: 'New Releases',
        playable: false,
        extras: {
          'browsable': true,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2,
        },
      ),
      const MediaItem(
        id: musicDiscoverId,
        title: 'Discover',
        playable: false,
        extras: {
          'browsable': true,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2,
        },
      ),
      const MediaItem(
        id: musicTrendingId,
        title: 'Trending',
        playable: false,
        extras: {
          'browsable': true,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2,
        },
      ),
    ];
  }

  /// Restituisce le sottocategorie di Preferiti
  static List<MediaItem> getFavoritesCategories() {
    return [
      const MediaItem(
        id: favoritesVideosId,
        title: 'Videos',
        playable: false,
        extras: {
          'browsable': true,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2,
        },
      ),
      const MediaItem(
        id: favoritesChannelsId,
        title: 'Channels',
        playable: false,
        extras: {
          'browsable': true,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2,
        },
      ),
      const MediaItem(
        id: favoritesPlaylistsId,
        title: 'Playlists',
        playable: false,
        extras: {
          'browsable': true,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2,
        },
      ),
    ];
  }

  /// Crea un folder per una categoria musicale con stile specifico
  static MediaItem getMusicCategoryFolder(String id, String title) {
    return MediaItem(
      id: id,
      title: '📂 $title',
      playable: false,
      extras: {
        'browsable': true,
        'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT':
            1, // Lista per le cartelle "Vedi tutto"
      },
    );
  }

  /// Crea un folder per una categoria preferiti con stile specifico
  static MediaItem getFavoritesCategoryFolder(String id, String title) {
    return MediaItem(
      id: id,
      title: '⭐ $title',
      playable: false,
      extras: {
        'browsable': true,
        'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 1,
      },
    );
  }

  // ============ Conversione Tiles -> MediaItem ============

  /// Converte un VideoTile in MediaItem (playable)
  static MediaItem videoTileToMediaItem(VideoTile tile) {
    return MediaItem(
      id: tile.id,
      title: tile.title,
      artist: tile.artist,
      artUri: Uri.tryParse(tile.thumbnailUrl),
      playable: true,
      extras: const {
        'browsable': false,
        'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT':
            2, // Griglia per i video
      },
    );
  }

  /// Converte un ChannelTile in MediaItem (browsable -> mostra video del canale)
  static MediaItem channelTileToMediaItem(ChannelTile tile) {
    return MediaItem(
      id: '$channelPrefix${tile.id}',
      title: tile.title,
      artist: tile.subscriberCount != null
          ? '${_formatSubscriberCount(tile.subscriberCount!)} iscritti'
          : null,
      artUri: Uri.tryParse(tile.thumbnailUrl),
      playable: false,
      extras: const {'browsable': true},
    );
  }

  /// Converte un PlaylistTile in MediaItem (browsable -> mostra video della playlist)
  static MediaItem playlistTileToMediaItem(PlaylistTile tile) {
    return MediaItem(
      id: '$playlistPrefix${tile.id}',
      title: tile.title,
      artist: tile.author,
      artUri: Uri.tryParse(tile.thumbnailUrl),
      playable: false,
      extras: {
        'browsable': true,
        'videoCount': tile.videoCount,
      },
    );
  }

  /// Converte una lista di VideoTile in lista di MediaItem
  static List<MediaItem> videoTilesToMediaItems(List<VideoTile> tiles) {
    return tiles.map(videoTileToMediaItem).toList();
  }

  /// Converte una lista di ChannelTile in lista di MediaItem
  static List<MediaItem> channelTilesToMediaItems(List<ChannelTile> tiles) {
    return tiles.map(channelTileToMediaItem).toList();
  }

  /// Converte una lista di PlaylistTile in lista di MediaItem
  static List<MediaItem> playlistTilesToMediaItems(List<PlaylistTile> tiles) {
    return tiles.map(playlistTileToMediaItem).toList();
  }

  // ============ Helper per parsing ID ============

  /// Verifica se l'ID è di un canale
  static bool isChannelId(String parentId) {
    return parentId.startsWith(channelPrefix);
  }

  /// Verifica se l'ID è di una playlist
  static bool isPlaylistId(String parentId) {
    return parentId.startsWith(playlistPrefix);
  }

  /// Verifica se l'ID è di risultati ricerca
  static bool isSearchResultsId(String parentId) {
    return parentId.startsWith(searchResultsPrefix);
  }

  /// Estrae l'ID reale del canale dal parentId
  static String extractChannelId(String parentId) {
    return parentId.substring(channelPrefix.length);
  }

  /// Estrae l'ID reale della playlist dal parentId
  static String extractPlaylistId(String parentId) {
    return parentId.substring(playlistPrefix.length);
  }

  /// Estrae la query di ricerca dal parentId
  static String extractSearchQuery(String parentId) {
    return parentId.substring(searchResultsPrefix.length);
  }

  // ============ Utility ============

  /// Formatta il conteggio iscritti in formato leggibile
  static String _formatSubscriberCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

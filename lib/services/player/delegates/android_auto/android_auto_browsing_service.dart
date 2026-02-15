part of '../../mt_player_service.dart';

/// Gestisce il content browsing e la ricerca per Android Auto,
/// incluso il caricamento dati da YouTube e dai preferiti.
class AndroidAutoBrowsingService {
  AndroidAutoBrowsingService(this._service);
  final MtPlayerService _service;

  static const int _searchPageSize = 20;
  final Map<String, SearchList> _searchListCache = {};
  final Map<String, List<dynamic>> _searchNextPageCache = {};

  // ============ Android Auto Media Playback ============

  Future<void> playMediaItem(MediaItem mediaItem) async {
    dev.log('playMediaItem called: ${mediaItem.id}');
    if (AndroidAutoContentHelper.isAddAllToQueueId(mediaItem.id)) {
      final parentId =
          AndroidAutoContentHelper.extractAddAllParentId(mediaItem.id);
      await _handleAddAllToQueue(parentId);
      return;
    }
    if (AndroidAutoContentHelper.isPlayAllId(mediaItem.id)) {
      final parentId =
          AndroidAutoContentHelper.extractPlayAllParentId(mediaItem.id);
      await _handlePlayAll(parentId);
      return;
    }
    if (mediaItem.playable == true) {
      // Se è un video singolo, lo mettiamo in playlist e lo riproduciamo
      final qm = _service._queueManager;
      qm.playlist = [mediaItem];
      qm.currentIndex = 0;
      qm.currentTrack = mediaItem;
      await _service._engine.playCurrentTrack();
    } else {
      // Se è una categoria/canale/playlist (browsable), Android Auto dovrebbe navigare,
      // ma se viene "riprodotta" direttamente la trattiamo come "seleziona e riproduci tutto"
      dev.log('Attempting to play browsable item: ${mediaItem.id}');
      // Qui potremmo caricare la lista di video e avviare la riproduzione del primo
    }
  }

  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    dev.log('playFromMediaId called: $mediaId');
    if (AndroidAutoContentHelper.isAddAllToQueueId(mediaId)) {
      final parentId = AndroidAutoContentHelper.extractAddAllParentId(mediaId);
      await _handleAddAllToQueue(parentId);
      return;
    }
    if (AndroidAutoContentHelper.isPlayAllId(mediaId)) {
      final parentId = AndroidAutoContentHelper.extractPlayAllParentId(mediaId);
      await _handlePlayAll(parentId);
      return;
    }
    // Implementazione speculare a playMediaItem o caricamento dinamico se necessario
    // Per ora, se è un video ID (non ha prefissi), lo riproduciamo
    if (!AndroidAutoContentHelper.isChannelId(mediaId) &&
        !AndroidAutoContentHelper.isPlaylistId(mediaId)) {
      // Carica i dettagli del video se non li abbiamo
      try {
        final videoDetails = await _service._engine.createMediaItem(mediaId);
        await playMediaItem(videoDetails);
      } catch (e) {
        dev.log('Errore in playFromMediaId: $e');
      }
    }
  }

  Future<void> addQueueItem(MediaItem mediaItem) async {
    try {
      final qm = _service._queueManager;

      if (mediaItem.playable == true) {
        final item = await _service._engine
            .createMediaItem(mediaItem.id, loadStreamUrl: false);
        final firstInsertedIndex = await qm.insertMediaItemsNext([item]);
        await qm.startIfIdle(firstInsertedIndex);
        return;
      }

      final mediaId = mediaItem.id;
      if (AndroidAutoContentHelper.isChannelId(mediaId)) {
        final channelId = AndroidAutoContentHelper.extractChannelId(mediaId);
        final items = await _getChannelVideos(channelId);
        final firstInsertedIndex = await qm.insertMediaItemsNext(items);
        await qm.startIfIdle(firstInsertedIndex);
        return;
      }

      if (AndroidAutoContentHelper.isPlaylistId(mediaId)) {
        final playlistId = AndroidAutoContentHelper.extractPlaylistId(mediaId);
        final items = await _getPlaylistVideos(playlistId);
        final firstInsertedIndex = await qm.insertMediaItemsNext(items);
        await qm.startIfIdle(firstInsertedIndex);
      }
    } catch (e) {
      dev.log('Errore durante addQueueItem: $e');
    }
  }

  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    try {
      if (mediaItems.isEmpty) return;

      final qm = _service._queueManager;
      final playableItems = <MediaItem>[];
      for (final mediaItem in mediaItems) {
        if (mediaItem.playable == true) {
          final item = await _service._engine
              .createMediaItem(mediaItem.id, loadStreamUrl: false);
          playableItems.add(item);
        } else if (AndroidAutoContentHelper.isChannelId(mediaItem.id)) {
          final channelId =
              AndroidAutoContentHelper.extractChannelId(mediaItem.id);
          playableItems.addAll(await _getChannelVideos(channelId));
        } else if (AndroidAutoContentHelper.isPlaylistId(mediaItem.id)) {
          final playlistId =
              AndroidAutoContentHelper.extractPlaylistId(mediaItem.id);
          playableItems.addAll(await _getPlaylistVideos(playlistId));
        }
      }

      final firstInsertedIndex = await qm.insertMediaItemsNext(playableItems);
      await qm.startIfIdle(firstInsertedIndex);
    } catch (e) {
      dev.log('Errore durante addQueueItems: $e');
    }
  }

  // ============ Android Auto Media Browsing ============

  /// Fornisce contenuti navigabili ad Android Auto
  Future<List<MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) async {
    dev.log('--- Android Auto getChildren ---');
    dev.log('ParentMediaId: "$parentMediaId"');
    dev.log('Options: $options');

    try {
      // Gestione ID Root: alcuni sistemi usano '/', altri 'root', ecc.
      if (parentMediaId == AndroidAutoContentHelper.rootId ||
          parentMediaId == 'root' ||
          parentMediaId == 'root_id') {
        dev.log('Returning Root Categories...');
        final root = AndroidAutoContentHelper.getRootCategories();
        dev.log('Root categories count: ${root.length}');
        return root;
      }

      switch (parentMediaId) {
        // Musica: hub esploso
        case AndroidAutoContentHelper.musicId:
          dev.log('Building Exploded Music Hub...');
          final hubItems = <MediaItem>[];

          // Nuove Uscite
          hubItems.add(AndroidAutoContentHelper.getMusicCategoryFolder(
              AndroidAutoContentHelper.musicNewReleasesId, 'New Releases'));
          final newReleases = await _getNewReleases(limit: 6);
          hubItems.addAll(newReleases);

          // Scopri
          hubItems.add(AndroidAutoContentHelper.getMusicCategoryFolder(
              AndroidAutoContentHelper.musicDiscoverId, 'Discover'));
          final discover = await _getDiscoverVideos(limit: 6);
          hubItems.addAll(discover);

          // Trending
          hubItems.add(AndroidAutoContentHelper.getMusicCategoryFolder(
              AndroidAutoContentHelper.musicTrendingId, 'Trending'));
          final trending = await _getTrendingMusic(limit: 6);
          hubItems.addAll(trending);

          return hubItems;

        // Preferiti: hub esploso
        case AndroidAutoContentHelper.favoritesId:
          dev.log('Building Exploded Favorites Hub...');
          final hubItemsFav = <MediaItem>[];

          // Video
          hubItemsFav.add(AndroidAutoContentHelper.getFavoritesCategoryFolder(
              AndroidAutoContentHelper.favoritesVideosId, 'My Videos'));
          final favVideos = await _getFavoriteVideos(limit: 10);
          hubItemsFav.addAll(favVideos);

          // Canali
          hubItemsFav.add(AndroidAutoContentHelper.getFavoritesCategoryFolder(
              AndroidAutoContentHelper.favoritesChannelsId, 'My Channels'));
          final favChannels = await _getFavoriteChannels(limit: 6);
          hubItemsFav.addAll(favChannels);

          // Playlist
          hubItemsFav.add(AndroidAutoContentHelper.getFavoritesCategoryFolder(
              AndroidAutoContentHelper.favoritesPlaylistsId, 'My Playlists'));
          final favPlaylists = await _getFavoritePlaylists(limit: 6);
          hubItemsFav.addAll(favPlaylists);

          return hubItemsFav;

        // Musica > Nuove Uscite (Lista completa)
        case AndroidAutoContentHelper.musicNewReleasesId:
          dev.log('Loading Full New Releases...');
          return _prependAddAllItem(parentMediaId, await _getNewReleases());

        // Musica > Scopri (video correlati ai preferiti)
        case AndroidAutoContentHelper.musicDiscoverId:
          dev.log('Loading Discover Videos...');
          return _prependAddAllItem(parentMediaId, await _getDiscoverVideos());

        // Musica > Trending
        case AndroidAutoContentHelper.musicTrendingId:
          dev.log('Loading Trending Music...');
          return _prependAddAllItem(parentMediaId, await _getTrendingMusic());

        // Preferiti > Video
        case AndroidAutoContentHelper.favoritesVideosId:
          dev.log('Loading Favorite Videos...');
          return _prependAddAllItem(parentMediaId, await _getFavoriteVideos());

        // Preferiti > Canali
        case AndroidAutoContentHelper.favoritesChannelsId:
          dev.log('Loading Favorite Channels...');
          return await _getFavoriteChannels();

        // Preferiti > Playlist
        case AndroidAutoContentHelper.favoritesPlaylistsId:
          dev.log('Loading Favorite Playlists...');
          return await _getFavoritePlaylists();

        // Ricerca > Cronologia ricerche
        case AndroidAutoContentHelper.searchId:
          dev.log('Loading Recent Searches...');
          return await _getRecentSearches();

        default:
          dev.log('Handling dynamic ID: $parentMediaId');
          if (AndroidAutoContentHelper.isSearchMoreId(parentMediaId)) {
            final query =
                AndroidAutoContentHelper.extractSearchMoreQuery(parentMediaId);
            dev.log('Loading more search results for query: $query');
            return await _getNextSearchResults(query);
          }
          // Gestione navigazione dinamica (canali, playlist)
          if (AndroidAutoContentHelper.isChannelId(parentMediaId)) {
            final channelId =
                AndroidAutoContentHelper.extractChannelId(parentMediaId);
            dev.log('Loading videos for channel: $channelId');
            return _prependAddAllItem(
                parentMediaId, await _getChannelVideos(channelId));
          }
          if (AndroidAutoContentHelper.isPlaylistId(parentMediaId)) {
            final playlistId =
                AndroidAutoContentHelper.extractPlaylistId(parentMediaId);
            dev.log('Loading videos for playlist: $playlistId');
            return _prependAddAllItem(
                parentMediaId, await _getPlaylistVideos(playlistId));
          }
          if (AndroidAutoContentHelper.isSearchResultsId(parentMediaId)) {
            final query =
                AndroidAutoContentHelper.extractSearchQuery(parentMediaId);
            dev.log('Loading search results for query: $query');
            return _prependAddAllItem(
                parentMediaId, await _getSearchResults(query));
          }
          dev.log('No children found for ID: $parentMediaId');
          return [];
      }
    } catch (e, stack) {
      dev.log('Errore in getChildren: $e');
      dev.log('Stack Trace: $stack');
      return [];
    }
  }

  /// Gestisce la ricerca vocale di Android Auto
  Future<List<MediaItem>> search(
    String query, [
    Map<String, dynamic>? extras,
  ]) async {
    dev.log('Android Auto search called with query: $query');

    if (_service.youtubeExplodeRepository == null || query.isEmpty) {
      return [];
    }

    try {
      final result =
          await _service.youtubeExplodeRepository!.searchContents(query: query);
      final items = result['items'] as List<dynamic>;
      final searchList = result['searchList'] as SearchList;
      _searchListCache[query] = searchList;

      final mediaItems = _buildSearchMediaItems(items);
      final showMore =
          await _shouldShowSearchMore(query, searchList, items.length);
      return _appendSearchMoreItem(query, mediaItems, showMore);
    } catch (e) {
      dev.log('Errore in search: $e');
      return [];
    }
  }

  // ============ Helper Methods ============

  Future<void> _handleAddAllToQueue(String parentMediaId) async {
    final items = await _getPlayableItemsForParent(parentMediaId);
    final firstInsertedIndex =
        await _service._queueManager.insertMediaItemsNext(items);
    await _service._queueManager.startIfIdle(firstInsertedIndex);
  }

  Future<void> _handlePlayAll(String parentMediaId) async {
    final items = await _getPlayableItemsForParent(parentMediaId);
    if (items.isEmpty) return;

    final qm = _service._queueManager;
    qm.playlist = items;
    qm.currentIndex = 0;
    qm.currentTrack = items[0];
    await _service._engine.playCurrentTrack();
  }

  List<MediaItem> _prependAddAllItem(
    String parentMediaId,
    List<MediaItem> items,
  ) {
    if (items.isEmpty) return items;
    return [
      AndroidAutoContentHelper.getPlayAllItem(parentMediaId),
      AndroidAutoContentHelper.getAddAllToQueueItem(parentMediaId),
      ...items,
    ];
  }

  List<MediaItem> _appendSearchMoreItem(
    String query,
    List<MediaItem> items,
    bool showMore,
  ) {
    if (!showMore) return items;
    return [...items, AndroidAutoContentHelper.getSearchMoreItem(query)];
  }

  Future<bool> _shouldShowSearchMore(
    String query,
    SearchList searchList,
    int currentCount,
  ) async {
    if (currentCount >= _searchPageSize) return true;
    if (_searchNextPageCache.containsKey(query)) {
      return _searchNextPageCache[query]!.isNotEmpty;
    }

    final nextItems =
        await _service.youtubeExplodeRepository!.nextSearchContents(searchList);
    _searchNextPageCache[query] = nextItems ?? [];
    return nextItems != null && nextItems.isNotEmpty;
  }

  List<MediaItem> _buildSearchMediaItems(List<dynamic> items) {
    final channels = <MediaItem>[];
    final playlists = <MediaItem>[];
    final videos = <MediaItem>[];

    for (final item in items) {
      if (item is ChannelTile) {
        channels.add(AndroidAutoContentHelper.channelTileToMediaItem(item));
      } else if (item is PlaylistTile) {
        playlists.add(AndroidAutoContentHelper.playlistTileToMediaItem(item));
      } else if (item is VideoTile) {
        videos.add(AndroidAutoContentHelper.videoTileToMediaItem(item));
      }
    }

    return [...channels, ...playlists, ...videos];
  }

  Future<List<MediaItem>> _getNextSearchResults(String query) async {
    final searchList = _searchListCache[query];
    if (searchList == null) return [];

    List<dynamic>? nextItems;
    if (_searchNextPageCache.containsKey(query)) {
      nextItems = _searchNextPageCache.remove(query);
      if (nextItems != null && nextItems.isEmpty) {
        nextItems = null;
      }
    } else {
      nextItems = await _service.youtubeExplodeRepository!
          .nextSearchContents(searchList);
    }
    if (nextItems == null || nextItems.isEmpty) return [];

    final mediaItems = _buildSearchMediaItems(nextItems);
    final showMore =
        await _shouldShowSearchMore(query, searchList, nextItems.length);
    return _appendSearchMoreItem(query, mediaItems, showMore);
  }

  Future<List<MediaItem>> _getPlayableItemsForParent(
      String parentMediaId) async {
    switch (parentMediaId) {
      case AndroidAutoContentHelper.musicNewReleasesId:
        return await _getNewReleases();
      case AndroidAutoContentHelper.musicDiscoverId:
        return await _getDiscoverVideos();
      case AndroidAutoContentHelper.musicTrendingId:
        return await _getTrendingMusic();
      case AndroidAutoContentHelper.favoritesVideosId:
        return await _getFavoriteVideos();
      default:
        if (AndroidAutoContentHelper.isChannelId(parentMediaId)) {
          final channelId =
              AndroidAutoContentHelper.extractChannelId(parentMediaId);
          return await _getChannelVideos(channelId);
        }
        if (AndroidAutoContentHelper.isPlaylistId(parentMediaId)) {
          final playlistId =
              AndroidAutoContentHelper.extractPlaylistId(parentMediaId);
          return await _getPlaylistVideos(playlistId);
        }
        if (AndroidAutoContentHelper.isSearchResultsId(parentMediaId)) {
          final query =
              AndroidAutoContentHelper.extractSearchQuery(parentMediaId);
          return await _getSearchResults(query);
        }
        return [];
    }
  }

  // ============ Data Loading ============

  Future<List<MediaItem>> _getNewReleases({int? limit}) async {
    try {
      final favoriteChannels =
          await _service.favoriteRepository!.favoriteChannels;
      if (favoriteChannels.isEmpty) return [];

      final List<VideoTile> newReleases = [];
      for (final channel in favoriteChannels) {
        try {
          final channelData =
              await _service.youtubeExplodeRepository!.getChannel(channel.id);
          final uploads = channelData['videos'] as List<VideoTile>;
          newReleases.addAll(uploads);

          // Se abbiamo un limite e lo abbiamo già superato per questo hub, fermati
          if (limit != null && newReleases.length >= limit) break;
        } catch (e) {
          dev.log('Errore caricamento video canale ${channel.id}: $e');
        }
      }

      final result = newReleases.toList();
      return AndroidAutoContentHelper.videoTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getNewReleases: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getDiscoverVideos({int? limit}) async {
    try {
      final favoriteVideos = await _service.favoriteRepository!.favoriteVideos;
      if (favoriteVideos.isEmpty) return [];

      final randomVideo =
          favoriteVideos[Random().nextInt(favoriteVideos.length)];
      final relatedVideos = await _service.youtubeExplodeRepository!
          .getRelatedVideos(randomVideo.id);

      final result = relatedVideos.toList();
      return AndroidAutoContentHelper.videoTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getDiscoverVideos: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getTrendingMusic({int? limit}) async {
    if (_service.youtubeExplodeRepository == null) return [];

    try {
      final trending =
          await _service.youtubeExplodeRepository!.getTrending('Music');
      final result = trending.toList();
      return AndroidAutoContentHelper.videoTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getTrendingMusic: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getFavoriteVideos({int? limit}) async {
    try {
      final videos = await _service.favoriteRepository!.favoriteVideos;
      final result = videos.reversed.toList();
      return AndroidAutoContentHelper.videoTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getFavoriteVideos: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getFavoriteChannels({int? limit}) async {
    try {
      final channels = await _service.favoriteRepository!.favoriteChannels;
      final result = channels.reversed.toList();
      return AndroidAutoContentHelper.channelTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getFavoriteChannels: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getFavoritePlaylists({int? limit}) async {
    try {
      final playlists = await _service.favoriteRepository!.favoritePlaylists;
      final result = playlists.reversed.toList();
      return AndroidAutoContentHelper.playlistTilesToMediaItems(
          limit != null ? result.take(limit).toList() : result);
    } catch (e) {
      dev.log('Errore in _getFavoritePlaylists: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getChannelVideos(String channelId) async {
    if (_service.youtubeExplodeRepository == null) return [];

    try {
      final channelData =
          await _service.youtubeExplodeRepository!.getChannel(channelId);
      final videos = channelData['videos'] as List<VideoTile>;
      return AndroidAutoContentHelper.videoTilesToMediaItems(videos.toList());
    } catch (e) {
      dev.log('Errore in _getChannelVideos: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getPlaylistVideos(String playlistId) async {
    if (_service.youtubeExplodeRepository == null) return [];

    try {
      final playlistData =
          await _service.youtubeExplodeRepository!.getPlaylist(playlistId);
      final videos = playlistData['videos'] as List<VideoTile>;
      return AndroidAutoContentHelper.videoTilesToMediaItems(videos.toList());
    } catch (e) {
      dev.log('Errore in _getPlaylistVideos: $e');
      return [];
    }
  }

  Future<List<MediaItem>> _getRecentSearches() async {
    try {
      final box = Hive.box('settings');
      if (box.containsKey('queryHistory')) {
        final history = jsonDecode(box.get('queryHistory')) as List<dynamic>;
        final queryHistory = history.map((e) => e.toString()).toList();

        return queryHistory
            .map((query) => MediaItem(
                  id: '${AndroidAutoContentHelper.searchResultsPrefix}$query',
                  title: query,
                  playable: false,
                  extras: const {
                    'browsable': true,
                    'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 1,
                    'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT': 1,
                  },
                ))
            .toList();
      }
    } catch (e) {
      dev.log('Errore in _getRecentSearches: $e');
    }
    return [];
  }

  Future<List<MediaItem>> _getSearchResults(String query) async {
    if (_service.youtubeExplodeRepository == null) return [];

    try {
      final result =
          await _service.youtubeExplodeRepository!.searchContents(query: query);
      final items = result['items'] as List<dynamic>;
      final searchList = result['searchList'] as SearchList;
      _searchListCache[query] = searchList;

      final mediaItems = _buildSearchMediaItems(items);
      final showMore =
          await _shouldShowSearchMore(query, searchList, items.length);
      return _appendSearchMoreItem(query, mediaItems, showMore);
    } catch (e) {
      dev.log('Errore in _getSearchResults: $e');
      return [];
    }
  }
}

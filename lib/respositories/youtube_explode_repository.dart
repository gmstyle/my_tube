import 'dart:developer';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:my_tube/models/channel_page_mt.dart';
import 'package:my_tube/models/music_home_mt.dart';
import 'package:my_tube/models/playlist_mt.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/providers/youtube_explode_provider.dart';
import 'package:my_tube/utils/enums.dart';

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

  Future<String?> _getBase64Thumbnail(String? url) async {
    final normalizedUrl = _normalizeUrl(url);
    return normalizedUrl != null
        ? await youtubeExplodeProvider.getBase64Image(normalizedUrl)
        : null;
  }

  /// Converte un Video di youtube_explode_dart in ResourceMT
  Future<ResourceMT> getResourceMTFromVideo(Video video,
      {String? streamUrl}) async {
    return ResourceMT(
      id: video.id.value,
      title: video.title,
      description: video.description,
      channelTitle: video.author,
      thumbnailUrl: _normalizeUrl(video.thumbnails.mediumResUrl),
      kind: Kind.video.name,
      channelId: video.channelId.value,
      playlistId: '',
      streamUrl: streamUrl,
      duration: video.duration?.inMilliseconds,
      base64Thumbnail: await _getBase64Thumbnail(video.thumbnails.mediumResUrl),
    );
  }

  /// Converte un SearchPlaylist di youtube_explode_dart in ResourceMT
  Future<ResourceMT> getResourceMTFromSearchPlaylist(
      SearchPlaylist playlist) async {
    return ResourceMT(
      id: playlist.id.value,
      title: playlist.title,
      description: '', // SearchPlaylist non ha description
      channelTitle: '', // SearchPlaylist non ha author
      thumbnailUrl: playlist.thumbnails.isNotEmpty
          ? _normalizeUrl(playlist.thumbnails.first.url.toString())
          : null,
      kind: Kind.playlist.name,
      channelId: null,
      playlistId: playlist.id.value,
      streamUrl: null,
      duration: null,
      videoCount: playlist.videoCount.toString(),
      base64Thumbnail: await _getBase64Thumbnail(playlist.thumbnails.isNotEmpty
          ? playlist.thumbnails.first.url.toString()
          : null),
    );
  }

  /// Converte un Playlist completo di youtube_explode_dart in ResourceMT
  Future<ResourceMT> getResourceMTFromPlaylist(Playlist playlist) async {
    // Per le playlist nei risultati di ricerca, proviamo a ottenere la thumbnail dal primo video
    String? thumbnailUrl;
    String? base64thumbnail;

    try {
      // Prova prima con la thumbnail della playlist
      thumbnailUrl = _normalizeUrl(playlist.thumbnails.mediumResUrl);
      base64thumbnail =
          await _getBase64Thumbnail(playlist.thumbnails.mediumResUrl);
    } catch (e) {
      // Se fallisce, prova a ottenere il primo video della playlist per la thumbnail
      try {
        final videos = await youtubeExplodeProvider
            .getPlaylistVideos(playlist.id.value, limit: 1);
        if (videos.isNotEmpty) {
          final firstVideo = videos.first;
          thumbnailUrl = _normalizeUrl(firstVideo.thumbnails.mediumResUrl);
          base64thumbnail =
              await _getBase64Thumbnail(firstVideo.thumbnails.mediumResUrl);
        }
      } catch (e2) {
        // Se anche questo fallisce, lascia null
        thumbnailUrl = null;
        base64thumbnail = null;
      }
    }

    return ResourceMT(
      id: playlist.id.value,
      title: playlist.title,
      description: playlist.description,
      channelTitle: playlist.author,
      thumbnailUrl: thumbnailUrl,
      kind: Kind.playlist.name,
      channelId: null,
      playlistId: playlist.id.value,
      streamUrl: null,
      duration: null,
      videoCount: playlist.videoCount?.toString(),
      base64Thumbnail: base64thumbnail,
    );
  }

  /// Converte un SearchChannel di youtube_explode_dart in ResourceMT
  Future<ResourceMT> getResourceMTFromSearchChannel(
      SearchChannel channel) async {
    return ResourceMT(
      id: channel.id.value,
      title: channel.name,
      description: channel.description,
      channelTitle: channel.name,
      thumbnailUrl: channel.thumbnails.isNotEmpty
          ? _normalizeUrl(channel.thumbnails.first.url.toString())
          : null,
      kind: Kind.channel.name,
      channelId: channel.id.value,
      playlistId: null,
      streamUrl: null,
      duration: null,
      subscriberCount: null, // SearchChannel non ha subscriber count
      videoCount: channel.videoCount.toString(),
      base64Thumbnail: await _getBase64Thumbnail(channel.thumbnails.isNotEmpty
          ? channel.thumbnails.first.url.toString()
          : null),
    );
  }

  /// Converte un SearchVideo completo di youtube_explode_dart in ResourceMT
  Future<ResourceMT> getResourceMTFromSearchVideo(SearchVideo video) async {
    return ResourceMT(
      id: video.id.value,
      title: video.title,
      description: video.description,
      channelTitle: video.author,
      thumbnailUrl: video.thumbnails.isNotEmpty
          ? _normalizeUrl(video.thumbnails.first.url.toString())
          : null,
      kind: Kind.video.name,
      channelId: video.channelId,
      playlistId: null,
      streamUrl: null,
      duration: int.tryParse(video.duration),
      videoCount: null,
      base64Thumbnail: await _getBase64Thumbnail(video.thumbnails.isNotEmpty
          ? video.thumbnails.first.url.toString()
          : null),
    );
  }

  /// Converte un Channel completo di youtube_explode_dart in ResourceMT
  Future<ResourceMT> getResourceMTFromChannel(Channel channel) async {
    return ResourceMT(
      id: channel.id.value,
      title: channel.title,
      description: '', // Channel non ha description diretta
      channelTitle: channel.title,
      thumbnailUrl: _normalizeUrl(channel.logoUrl),
      kind: Kind.channel.name,
      channelId: channel.id.value,
      playlistId: null,
      streamUrl: null,
      duration: null,
      subscriberCount: null, // Channel non ha subscriber count esposto
      videoCount: null, // Channel non ha video count esposto
      base64Thumbnail: await _getBase64Thumbnail(channel.logoUrl),
    );
  }

  /// Converte una Playlist completa in PlaylistMT
  Future<PlaylistMT> _getPlaylistMTFromPlaylist(
      Playlist playlist, List<Video>? videos) async {
    final videoResources = videos != null
        ? await Future.wait(
            videos.map((video) => getResourceMTFromVideo(video)))
        : <ResourceMT>[];

    // Per le playlist, usa la thumbnail del primo video se disponibile
    String? thumbnailUrl;
    String? base64thumbnail;

    if (videos != null && videos.isNotEmpty) {
      // Usa la thumbnail del primo video
      final firstVideo = videos.first;
      thumbnailUrl = _normalizeUrl(firstVideo.thumbnails.mediumResUrl);
      base64thumbnail =
          await _getBase64Thumbnail(firstVideo.thumbnails.mediumResUrl);
    } else {
      // Fallback alla thumbnail della playlist (se esiste)
      try {
        thumbnailUrl = _normalizeUrl(playlist.thumbnails.mediumResUrl);
        base64thumbnail =
            await _getBase64Thumbnail(playlist.thumbnails.mediumResUrl);
      } catch (e) {
        // Se non c'è thumbnail, lascialo null
        thumbnailUrl = null;
        base64thumbnail = null;
      }
    }

    return PlaylistMT(
      id: playlist.id.value,
      channelId: null,
      title: playlist.title,
      description: playlist.description,
      thumbnailUrl: thumbnailUrl,
      base64Thumbnail: base64thumbnail,
      itemCount: playlist.videoCount?.toString(),
      videos: videoResources,
    );
  }

  /// Recupera un video singolo
  Future<ResourceMT> getVideo(String videoId, {bool? withStreamUrl}) async {
    try {
      final video =
          await youtubeExplodeProvider.getVideo(videoId, withStreamUrl);

      String? streamUrl;
      if (withStreamUrl == true) {
        try {
          // Ottieni il manifest dello stream per trovare l'URL di riproduzione
          final manifest =
              await youtubeExplodeProvider.getVideoStreamManifest(videoId);
          // Prendi il primo stream muxed disponibile (audio + video)
          final muxedStream = manifest.muxed.firstOrNull;
          if (muxedStream != null) {
            streamUrl = muxedStream.url.toString();
          } else {
            // Se non c'è stream muxed, prova con audio stream come fallback
            final audioStream = manifest.audioOnly.withHighestBitrate();
            streamUrl = audioStream.url.toString();
          }
        } catch (e) {
          log('Errore durante il recupero dello stream URL: $e');
          // Continua senza stream URL
        }
      }

      return await getResourceMTFromVideo(video, streamUrl: streamUrl);
    } catch (e) {
      log('Errore durante il recupero del video: $e');
      rethrow;
    }
  }

  /// Simula getTrending usando ricerche predefinite
  Future<ResponseMT> getTrending(String trendingCategory) async {
    try {
      log('getTrending chiamato con categoria: $trendingCategory');
      // Passa direttamente la categoria al provider senza ulteriore mapping
      final videos =
          await youtubeExplodeProvider.getTrendingSimulated(trendingCategory);
      final resources = await Future.wait(
          videos.map((video) => getResourceMTFromVideo(video)));
      log('getTrending completato, ${resources.length} video trovati per categoria: $trendingCategory');
      return ResponseMT(resources: resources, nextPageToken: null);
    } catch (e) {
      log('Errore durante il recupero dei trending video: $e');
      rethrow;
    }
  }

  /// Simula getMusicHome usando ricerche musicali predefinite
  Future<MusicHomeMT> getMusicHome() async {
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
  }

  /// Recupera una playlist
  Future<PlaylistMT> getPlaylist(String playlistId,
      {bool getVideos = true}) async {
    try {
      final playlist = await youtubeExplodeProvider.getPlaylist(playlistId,
          getVideos: false);

      List<Video>? videos;
      if (getVideos) {
        videos = await youtubeExplodeProvider.getPlaylistVideos(playlistId);
      }

      return await _getPlaylistMTFromPlaylist(playlist, videos);
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
  Future<ResponseMT> searchContents({required String query}) async {
    try {
      final resources = <ResourceMT>[];

      // Usa il nuovo metodo unificato di ricerca
      final searchResults =
          await youtubeExplodeProvider.searchContent(query, limit: 50);

      // Processa i risultati in base al tipo
      for (final result in searchResults) {
        try {
          if (result is SearchVideo) {
            final videoResource = await getResourceMTFromSearchVideo(result);
            resources.add(videoResource);
          } else if (result is SearchChannel) {
            final channelResource =
                await getResourceMTFromSearchChannel(result);
            resources.add(channelResource);
          } else if (result is SearchPlaylist) {
            final playlistResource =
                await getResourceMTFromSearchPlaylist(result);
            resources.add(playlistResource);
          }
        } catch (e) {
          // Se c'è un errore nella conversione di un singolo risultato,
          // continua con il prossimo senza interrompere tutta la ricerca
          log('Errore nella conversione di un risultato di ricerca: $e');
          continue;
        }
      }

      return ResponseMT(
        resources: resources,
        nextPageToken: null, // Rimossa la paginazione
      );
    } catch (e) {
      log('Errore durante la ricerca dei contenuti: $e');
      rethrow;
    }
  }

  /// Recupera informazioni di un canale
  Future<ChannelPageMT> getChannel(String channelId) async {
    try {
      final channel = await youtubeExplodeProvider.getChannel(channelId);
      final uploads =
          await youtubeExplodeProvider.getChannelUploads(channelId, limit: 30);

      final uploadsResources = await Future.wait(
          uploads.map((video) => getResourceMTFromVideo(video)));

      final sections = <SectionMT>[
        SectionMT(
          title: 'Uploads',
          playlistId: null,
          videos: uploadsResources,
          playlists: [],
          channels: [],
        ),
      ];

      return ChannelPageMT(
        title: channel.title,
        description: '', // Channel non ha description diretta
        channelHandleText: null, // Non disponibile in youtube_explode_dart
        avatarUrl: _normalizeUrl(channel.logoUrl),
        bannerUrl: null, // Non disponibile in Channel base
        thumbnailUrl: _normalizeUrl(channel.logoUrl),
        tvBannerUrl: null,
        sections: sections,
        subscriberCount: null,
        videoCount: null,
      );
    } catch (e) {
      log('Errore durante il recupero del canale: $e');
      rethrow;
    }
  }
}

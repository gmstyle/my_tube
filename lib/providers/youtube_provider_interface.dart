import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Interfaccia comune per i provider YouTube
/// Permette di switchare facilmente tra InnertubeProvider e YoutubeExplodeProvider
abstract class YouTubeProviderInterface {
  // Metodi base per video
  Future<Video> getVideo(String videoId, bool? withStreamUrl);

  // Metodi per playlist
  Future<Playlist> getPlaylist(String playlistId, {bool getVideos = true});
  Future<List<Video>> getPlaylistVideos(String playlistId, {int limit = 50});

  // Metodi per canali
  Future<Channel> getChannel(String channelId);
  Future<List<Video>> getChannelUploads(String channelId, {int limit = 50});

  // Metodo di ricerca unificato (sostituisce searchVideos, searchChannels, searchPlaylists)
  Future<List<dynamic>> searchContent(String query, {int limit = 50});
  Future<List<String>> getSearchSuggestions(String query);

  // Metodi simulati per funzionalità mancanti
  Future<List<Video>> getTrendingSimulated(String category);
  Future<List<Video>> getMusicHomeSimulated();

  // Metodi per stream
  Future<StreamManifest> getVideoStreamManifest(String videoId);

  // Cleanup
  void close();
}

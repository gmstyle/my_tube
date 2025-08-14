import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/models/tiles.dart' as models;

class FavoriteRepository {
  final YoutubeExplodeRepository youtubeExplodeRepository;

  FavoriteRepository({required this.youtubeExplodeRepository});

  final favoriteVideosBox = Hive.box<String>('favoriteVideos');
  final favoriteChannelsBox = Hive.box<String>('favoriteChannels');
  final favoritePlaylistsBox = Hive.box<String>('favoritePlaylists');

  Future<List<models.VideoTile>> get favoriteVideos async =>
      await Future.wait(favoriteVideosBox.values.toList().map((id) async {
        return await youtubeExplodeRepository.getVideoMetadata(id);
      }));
  Future<List<models.ChannelTile>> get favoriteChannels async =>
      await Future.wait(favoriteChannelsBox.values.toList().map((id) async {
        return await youtubeExplodeRepository.getChannelMetadata(id);
      }));
  Future<List<models.PlaylistTile>> get favoritePlaylists async =>
      await Future.wait(favoritePlaylistsBox.values.toList().map((id) async {
        return await youtubeExplodeRepository.getPlaylistMetadata(id);
      }));

  List<String> get videoIds => favoriteVideosBox.values.toList();
  List<String> get channelIds => favoriteChannelsBox.values.toList();
  List<String> get playlistIds => favoritePlaylistsBox.values.toList();

  ValueListenable<Box<String>> get favoriteVideosListenable =>
      favoriteVideosBox.listenable();
  ValueListenable<Box<String>> get favoriteChannelsListenable =>
      favoriteChannelsBox.listenable();
  ValueListenable<Box<String>> get favoritePlaylistsListenable =>
      favoritePlaylistsBox.listenable();

  Future<void> addVideo(String id) async {
    await favoriteVideosBox.add(id);
  }

  Future<void> addChannel(String id) async {
    await favoriteChannelsBox.add(id);
  }

  Future<void> addPlaylist(String id) async {
    await favoritePlaylistsBox.add(id);
  }

  Future<void> addAllVideos(List<String> favorites) async {
    await favoriteVideosBox.addAll(favorites);
  }

  Future<void> addAllChannels(List<String> favorites) async {
    await favoriteChannelsBox.addAll(favorites);
  }

  Future<void> addAllPlaylists(List<String> favorites) async {
    await favoritePlaylistsBox.addAll(favorites);
  }

  Future<void> removeVideo(String id) async {
    final index = favoriteVideosBox.keys.toList().indexOf(id);
    await favoriteVideosBox.deleteAt(index);
  }

  Future<void> removeChannel(String id) async {
    final index = favoriteChannelsBox.keys.toList().indexOf(id);
    await favoriteChannelsBox.deleteAt(index);
  }

  Future<void> removePlaylist(String id) async {
    final index = favoritePlaylistsBox.keys.toList().indexOf(id);
    await favoritePlaylistsBox.deleteAt(index);
  }

  Future<void> clearVideos() async {
    await favoriteVideosBox.clear();
  }

  Future<void> clearChannels() async {
    await favoriteChannelsBox.clear();
  }

  Future<void> clearPlaylists() async {
    await favoritePlaylistsBox.clear();
  }
}

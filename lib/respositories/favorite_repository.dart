import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/utils/constants.dart';

class FavoriteRepository {
  final YoutubeExplodeRepository youtubeExplodeRepository;

  FavoriteRepository({required this.youtubeExplodeRepository});

  final favoriteVideosBox = Hive.box<String>(hiveFavoriteVideosBoxName);
  final favoriteChannelsBox = Hive.box<String>(hiveFavoriteChannelsBoxName);
  final favoritePlaylistsBox = Hive.box<String>(hiveFavoritePlaylistsBoxName);
  final recentlyPlayedBox = Hive.box<String>(hiveRecentlyPlayedBoxName);

  /// Saves [id] at the head of the recently-played list.
  /// Duplicates are removed and the list is capped at [recentlyPlayedMaxStored].
  Future<void> addRecentlyPlayed(String id) async {
    // Remove existing entry for this id to avoid duplicates
    final duplicateKey = recentlyPlayedBox
        .toMap()
        .entries
        .where((e) => e.value == id)
        .map((e) => e.key)
        .firstOrNull;
    if (duplicateKey != null) await recentlyPlayedBox.delete(duplicateKey);
    // Append to end (most recent = last)
    await recentlyPlayedBox.add(id);
    // Trim oldest entries
    while (recentlyPlayedBox.length > recentlyPlayedMaxStored) {
      await recentlyPlayedBox.delete(recentlyPlayedBox.keys.first);
    }
  }

  /// Returns the last 20 played videos, most recent first.
  Future<List<models.VideoTile>> get recentlyPlayed async {
    final ids = recentlyPlayedBox.values
        .toList()
        .reversed
        .take(recentlyPlayedMaxReturned)
        .toList();
    final results = await Future.wait(ids.map((id) async {
      try {
        return await youtubeExplodeRepository.getVideoMetadata(id);
      } catch (_) {
        return null;
      }
    }));
    return results.whereType<models.VideoTile>().toList();
  }

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
    // Find the key corresponding to the stored value and delete by key.
    final matchingKeys = favoriteVideosBox.keys
        .where((k) => favoriteVideosBox.get(k) == id)
        .toList();
    if (matchingKeys.isNotEmpty) {
      await favoriteVideosBox.delete(matchingKeys.first);
    }
  }

  Future<void> removeChannel(String id) async {
    final matchingKeys = favoriteChannelsBox.keys
        .where((k) => favoriteChannelsBox.get(k) == id)
        .toList();
    if (matchingKeys.isNotEmpty) {
      await favoriteChannelsBox.delete(matchingKeys.first);
    }
  }

  Future<void> removePlaylist(String id) async {
    final matchingKeys = favoritePlaylistsBox.keys
        .where((k) => favoritePlaylistsBox.get(k) == id)
        .toList();
    if (matchingKeys.isNotEmpty) {
      await favoritePlaylistsBox.delete(matchingKeys.first);
    }
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

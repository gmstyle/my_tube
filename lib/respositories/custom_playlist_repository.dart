import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:my_tube/models/custom_playlist.dart';
import 'package:my_tube/utils/constants.dart';
import 'package:uuid/uuid.dart';

class CustomPlaylistRepository {
  final customPlaylistsBox = Hive.box<String>(hiveCustomPlaylistsBoxName);
  final _uuid = const Uuid();

  List<CustomPlaylist> getPlaylists() {
    return customPlaylistsBox.values
        .map((e) => CustomPlaylist.fromJson(e))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  ValueListenable<Box<String>> get customPlaylistsListenable =>
      customPlaylistsBox.listenable();

  Future<void> createPlaylist(String title) async {
    final id = _uuid.v4();
    final newPlaylist = CustomPlaylist(
      id: id,
      title: title,
      videoIds: const [],
      createdAt: DateTime.now(),
    );
    await customPlaylistsBox.put(id, newPlaylist.toJson());
  }

  Future<void> deletePlaylist(String id) async {
    await customPlaylistsBox.delete(id);
  }

  Future<void> updatePlaylistTitle(String id, String newTitle) async {
    final jsonStr = customPlaylistsBox.get(id);
    if (jsonStr != null) {
      final playlist = CustomPlaylist.fromJson(jsonStr);
      final updated = playlist.copyWith(title: newTitle);
      await customPlaylistsBox.put(id, updated.toJson());
    }
  }

  Future<void> addVideoToPlaylist(String playlistId, String videoId) async {
    final jsonStr = customPlaylistsBox.get(playlistId);
    if (jsonStr != null) {
      final playlist = CustomPlaylist.fromJson(jsonStr);
      if (!playlist.videoIds.contains(videoId)) {
        final updated = playlist.copyWith(videoIds: [...playlist.videoIds, videoId]);
        await customPlaylistsBox.put(playlistId, updated.toJson());
      }
    }
  }

  Future<void> removeVideoFromPlaylist(String playlistId, String videoId) async {
    final jsonStr = customPlaylistsBox.get(playlistId);
    if (jsonStr != null) {
      final playlist = CustomPlaylist.fromJson(jsonStr);
      final updatedList = playlist.videoIds.where((id) => id != videoId).toList();
      final updated = playlist.copyWith(videoIds: updatedList);
      await customPlaylistsBox.put(playlistId, updated.toJson());
    }
  }

  CustomPlaylist? getPlaylist(String id) {
     final jsonStr = customPlaylistsBox.get(id);
     if (jsonStr != null) return CustomPlaylist.fromJson(jsonStr);
     return null;
  }
}

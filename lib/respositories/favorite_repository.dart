import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';

class FavoriteRepository {
  final InnertubeRepository innertubeRepository;

  FavoriteRepository({required this.innertubeRepository});

  final favoriteVideosBox = Hive.box<ResourceMT>('favorites');
  final favoriteChannelsBox = Hive.box<ResourceMT>('channels');
  final favoritePlaylistsBox = Hive.box<ResourceMT>('playlists');

  List<ResourceMT> get favoriteVideos => favoriteVideosBox.values.toList();
  List<ResourceMT> get favoriteChannels => favoriteChannelsBox.values.toList();
  List<ResourceMT> get favoritePlaylists =>
      favoritePlaylistsBox.values.toList();

  List<String> get videoIds => favoriteVideos.map((e) => e.id!).toList();
  List<String> get channelIds => favoriteChannels.map((e) => e.id!).toList();
  List<String> get playlistIds => favoritePlaylists.map((e) => e.id!).toList();

  ValueListenable<Box<ResourceMT>> get favoriteVideosListenable =>
      favoriteVideosBox.listenable();
  ValueListenable<Box<ResourceMT>> get favoriteChannelsListenable =>
      favoriteChannelsBox.listenable();
  ValueListenable<Box<ResourceMT>> get favoritePlaylistsListenable =>
      favoritePlaylistsBox.listenable();

  Future<void> add(ResourceMT favorite, String kind) async {
    if (kind == 'video') {
      await favoriteVideosBox.add(favorite);
    } else if (kind == 'channel') {
      await favoriteChannelsBox.add(favorite);
    } else if (kind == 'playlist') {
      await favoritePlaylistsBox.add(favorite);
    }
  }

  Future<void> addAll(List<ResourceMT> favorites, String kind) async {
    if (kind == 'video') {
      await favoriteVideosBox.addAll(favorites);
    } else if (kind == 'channel') {
      await favoriteChannelsBox.addAll(favorites);
    } else if (kind == 'playlist') {
      await favoritePlaylistsBox.addAll(favorites);
    }
  }

  Future<void> remove(String id, String kind) async {
    if (kind == 'video') {
      final index = favoriteVideos.indexWhere((element) => element.id == id);
      await favoriteVideosBox.deleteAt(index);
    } else if (kind == 'channel') {
      final index = favoriteChannels.indexWhere((element) => element.id == id);
      await favoriteChannelsBox.deleteAt(index);
    } else if (kind == 'playlist') {
      final index = favoritePlaylists.indexWhere((element) => element.id == id);
      await favoritePlaylistsBox.deleteAt(index);
    }
  }

  Future<void> clear(String kind) async {
    if (kind == 'video') {
      await favoriteVideosBox.clear();
    } else if (kind == 'channel') {
      await favoriteChannelsBox.clear();
    } else if (kind == 'playlist') {
      await favoritePlaylistsBox.clear();
    }
  }

  Future<bool> contains(String? id, String kind) async {
    if (kind == 'video') {
      return favoriteVideosBox.containsKey(id);
    } else if (kind == 'channel') {
      return favoriteChannelsBox.containsKey(id);
    } else if (kind == 'playlist') {
      return favoritePlaylistsBox.containsKey(id);
    }
    return false;
  }

  Future<void> migrateData() async {
    // Migrate favorite playlists with base64 thumbnails if they don't have one
    final canMigrate = favoritePlaylists.isNotEmpty &&
        favoritePlaylists.every((playlist) => playlist.base64Thumbnail == null);

    if (canMigrate) {
      final updatedPlaylists =
          await Future.wait(favoritePlaylists.map((savedPlaylist) async {
        final newPlaylist = await innertubeRepository
            .getPlaylist(savedPlaylist.id!, getVideos: false);

        var base64thumbnail = await innertubeRepository.innertubeProvider
            .getBase64Image(newPlaylist.thumbnailUrl!);
        return savedPlaylist.copyWith(base64Thumbnail: base64thumbnail);
      }));
      await favoritePlaylistsBox.clear();
      await favoritePlaylistsBox.addAll(updatedPlaylists);
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/utils/enums.dart';

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

  Future<void> add(ResourceMT favorite, Kind kind) async {
    if (kind == Kind.video) {
      await favoriteVideosBox.add(favorite);
    } else if (kind == Kind.channel) {
      await favoriteChannelsBox.add(favorite);
    } else if (kind == Kind.playlist) {
      await favoritePlaylistsBox.add(favorite);
    }
  }

  Future<void> addAll(List<ResourceMT> favorites, Kind kind) async {
    if (kind == Kind.video) {
      await favoriteVideosBox.addAll(favorites);
    } else if (kind == Kind.channel) {
      await favoriteChannelsBox.addAll(favorites);
    } else if (kind == Kind.playlist) {
      await favoritePlaylistsBox.addAll(favorites);
    }
  }

  Future<void> remove(String id, Kind kind) async {
    if (kind == Kind.video) {
      final index = favoriteVideos.indexWhere((element) => element.id == id);
      await favoriteVideosBox.deleteAt(index);
    } else if (kind == Kind.channel) {
      final index = favoriteChannels.indexWhere((element) => element.id == id);
      await favoriteChannelsBox.deleteAt(index);
    } else if (kind == Kind.playlist) {
      final index = favoritePlaylists.indexWhere((element) => element.id == id);
      await favoritePlaylistsBox.deleteAt(index);
    }
  }

  Future<void> clear(Kind kind) async {
    if (kind == Kind.video) {
      await favoriteVideosBox.clear();
    } else if (kind == Kind.channel) {
      await favoriteChannelsBox.clear();
    } else if (kind == Kind.playlist) {
      await favoritePlaylistsBox.clear();
    }
  }

  Future<bool> contains(String? id, Kind kind) async {
    if (kind == Kind.video) {
      return favoriteVideosBox.containsKey(id);
    } else if (kind == Kind.channel) {
      return favoriteChannelsBox.containsKey(id);
    } else if (kind == Kind.playlist) {
      return favoritePlaylistsBox.containsKey(id);
    }
    return false;
  }

  Future<void> migrateData() async {
    // Migrate favorite playlists with base64 thumbnails if they don't have one
    final canMigratePlaylist = favoritePlaylists.isNotEmpty &&
        favoritePlaylists.every((playlist) => playlist.base64Thumbnail == null);

    if (canMigratePlaylist) {
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

    // Migrate favorite channels with base64 thumbnails if they don't have one
    final canMigrateChannels = favoriteChannels.isNotEmpty &&
        favoriteChannels.any((channel) =>
            channel.base64Thumbnail == null ||
            channel.base64Thumbnail!.isEmpty);

    if (canMigrateChannels) {
      final updatedChannels =
          await Future.wait(favoriteChannels.map((savedChannel) async {
        try {
          // Only migrate channels that don't have base64Thumbnail
          if (savedChannel.base64Thumbnail == null ||
              savedChannel.base64Thumbnail!.isEmpty) {
            final channelDetails =
                await innertubeRepository.getChannel(savedChannel.channelId!);

            // Get the image URL, prioritizing avatarUrl from channel details
            final imageUrl =
                channelDetails.avatarUrl ?? savedChannel.thumbnailUrl;

            if (imageUrl != null && imageUrl.isNotEmpty) {
              var base64thumbnail = await innertubeRepository.innertubeProvider
                  .getBase64Image(imageUrl);

              return savedChannel.copyWith(base64Thumbnail: base64thumbnail);
            }
          }
          return savedChannel; // Return unchanged if already has base64Thumbnail or no valid URL
        } catch (e) {
          // If migration fails for a specific channel, return the original
          return savedChannel;
        }
      }));
      await favoriteChannelsBox.clear();
      await favoriteChannelsBox.addAll(updatedChannels);
    }
  }
}

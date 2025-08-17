import 'package:equatable/equatable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoTile extends Equatable {
  final String id;
  final String title;
  final String? artist;
  final String thumbnailUrl;

  const VideoTile({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
  });

  factory VideoTile.fromVideo(Video video) {
    return VideoTile(
      id: video.id.value,
      title: video.title,
      artist: video.musicData.isNotEmpty ? video.musicData.first.artist : null,
      thumbnailUrl: video.thumbnails.highResUrl,
    );
  }

  factory VideoTile.fromSearchVideo(SearchVideo video) {
    return VideoTile(
      id: video.id.value,
      title: video.title,
      artist: video.author,
      thumbnailUrl: video.thumbnails.first.url.toString(),
    );
  }

  @override
  List<Object?> get props => [id, title, artist, thumbnailUrl];
}

class ChannelTile extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final int? subscriberCount;

  const ChannelTile({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.subscriberCount,
  });

  factory ChannelTile.fromChannel(Channel channel) {
    return ChannelTile(
      id: channel.id.value,
      title: channel.title,
      description: '',
      thumbnailUrl: channel.logoUrl,
      subscriberCount: channel.subscribersCount,
    );
  }

  factory ChannelTile.fromSearchChannel(SearchChannel channel) {
    return ChannelTile(
      id: channel.id.value,
      title: channel.name,
      description: channel.description,
      thumbnailUrl: channel.thumbnails.first.url.toString(),
      subscriberCount: null,
    );
  }

  @override
  List<Object?> get props => [id, title, thumbnailUrl, subscriberCount];
}

class PlaylistTile extends Equatable {
  final String id;
  final String title;
  final String? author;
  final String thumbnailUrl;
  final int? videoCount;

  const PlaylistTile({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.videoCount,
  });

  factory PlaylistTile.fromPlaylist(Playlist playlist) {
    return PlaylistTile(
      id: playlist.id.value,
      title: playlist.title,
      author: playlist.author,
      thumbnailUrl: playlist.thumbnails.highResUrl,
      videoCount: playlist.videoCount,
    );
  }

  factory PlaylistTile.fromSearchPlaylist(SearchPlaylist playlist) {
    return PlaylistTile(
      id: playlist.id.value,
      title: playlist.title,
      author: null,
      thumbnailUrl: playlist.thumbnails.first.url.toString(),
      videoCount: playlist.videoCount,
    );
  }

  @override
  List<Object?> get props => [id, title, author, thumbnailUrl, videoCount];
}

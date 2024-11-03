import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';

class PlaylistResponseMT extends Equatable {
  final PlaylistMT? playlist;
  final String? nextPageToken;

  const PlaylistResponseMT({
    required this.playlist,
    required this.nextPageToken,
  });

  factory PlaylistResponseMT.fromJson(Map<String, dynamic> json) {
    return PlaylistResponseMT(
      playlist: json['playlist'] != null
          ? PlaylistMT.fromJson(json['playlist'] as Map<String, dynamic>)
          : null,
      nextPageToken: json['nextPageToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlist': playlist,
      'nextPageToken': nextPageToken,
    };
  }

  PlaylistResponseMT copyWith({
    PlaylistMT? playlist,
    String? nextPageToken,
  }) {
    return PlaylistResponseMT(
      playlist: playlist ?? this.playlist,
      nextPageToken: nextPageToken ?? this.nextPageToken,
    );
  }

  @override
  List<Object?> get props => [
        playlist,
        nextPageToken,
      ];
}

class PlaylistMT extends Equatable {
  final String? id;
  final String? channelId;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? base64Thumbnail;
  final String? itemCount;
  final List<ResourceMT>? videos;

  const PlaylistMT({
    required this.id,
    required this.channelId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.base64Thumbnail,
    required this.itemCount,
    required this.videos,
  });

  factory PlaylistMT.fromJson(Map<String, dynamic> json) {
    return PlaylistMT(
      id: json['id'],
      channelId: json['channelId'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      base64Thumbnail: json['base64Thumbnail'],
      itemCount: json['itemCount'],
      videos: json['videos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'base64Thumbnail': base64Thumbnail,
      'itemCount': itemCount,
      'videos': videos,
    };
  }

  @override
  List<Object?> get props => [
        id,
        channelId,
        title,
        description,
        thumbnailUrl,
        itemCount,
        videos,
      ];
}

import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/utils/enums.dart';
part 'resource_mt.g.dart';

class ResponseMT extends Equatable {
  final List<ResourceMT> resources;
  final String? nextPageToken;

  const ResponseMT({
    required this.resources,
    required this.nextPageToken,
  });

  factory ResponseMT.fromJson(Map<String, dynamic> json) {
    final videos = (json['resources'] as List)
        .map((e) => ResourceMT.fromJson(e as Map<String, dynamic>))
        .toList();
    return ResponseMT(
      resources: videos,
      nextPageToken: json['nextPageToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resources': resources,
      'nextPageToken': nextPageToken,
    };
  }

  ResponseMT copyWith({
    List<ResourceMT>? resources,
    String? nextPageToken,
  }) {
    return ResponseMT(
      resources: resources ?? this.resources,
      nextPageToken: nextPageToken ?? this.nextPageToken,
    );
  }

  @override
  List<Object?> get props => [resources, nextPageToken];
}

@HiveType(typeId: 1)
// ignore: must_be_immutable
class ResourceMT extends Equatable with HiveObjectMixin {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? channelTitle;

  @HiveField(4)
  final String? thumbnailUrl;

  @HiveField(5)
  final String? kind;

  @HiveField(6)
  final String? channelId;

  @HiveField(7)
  final String? playlistId;

  @HiveField(8)
  final String? streamUrl;

  @HiveField(9)
  final int? duration;

  @HiveField(10)
  final DateTime? addedAt;

  @HiveField(11)
  final String? subscriberCount;

  @HiveField(12)
  final String? videoCount;

  @HiveField(13)
  final String? base64Thumbnail;

  ResourceMT({
    required this.id,
    required this.title,
    required this.description,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.kind,
    required this.channelId,
    required this.playlistId,
    required this.streamUrl,
    required this.duration,
    this.addedAt,
    this.subscriberCount,
    this.videoCount,
    this.base64Thumbnail,
  });

  factory ResourceMT.fromJson(Map<String, dynamic> json) {
    return ResourceMT(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      channelTitle: json['channelTitle'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      kind: json['kind'] as String?,
      channelId: json['channelId'] as String?,
      playlistId: json['playlistId'] as String?,
      streamUrl: json['streamUrl'] as String?,
      duration: json['duration'] as int?,
      addedAt: json['addedAt'] == null
          ? null
          : DateTime.parse(json['addedAt'] as String),
      subscriberCount: json['subscriberCount'] as String?,
      videoCount: json['videoCount'] as String?,
      base64Thumbnail: json['base64Thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'channelTitle': channelTitle,
      'thumbnailUrl': thumbnailUrl,
      'kind': kind,
      'channelId': channelId,
      'playlistId': playlistId,
      'streamUrl': streamUrl,
      'duration': duration,
      'addedAt': addedAt?.toIso8601String(),
      'subscriberCount': subscriberCount,
      'videoCount': videoCount,
      'base64Thumbnail': base64Thumbnail,
    };
  }

  ResourceMT copyWith({
    String? id,
    String? title,
    String? description,
    String? channelTitle,
    String? thumbnailUrl,
    String? kind,
    String? channelId,
    String? playlistId,
    String? streamUrl,
    int? duration,
    DateTime? addedAt,
    String? subscriberCount,
    String? videoCount,
    String? base64Thumbnail,
  }) {
    return ResourceMT(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      channelTitle: channelTitle ?? this.channelTitle,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      kind: kind ?? this.kind,
      channelId: channelId ?? this.channelId,
      playlistId: playlistId ?? this.playlistId,
      streamUrl: streamUrl ?? this.streamUrl,
      duration: duration ?? this.duration,
      addedAt: addedAt ?? this.addedAt,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      videoCount: videoCount ?? this.videoCount,
      base64Thumbnail: base64Thumbnail ?? this.base64Thumbnail,
    );
  }

  factory ResourceMT.fromMediaItem(MediaItem mediaItem) {
    return ResourceMT(
      id: mediaItem.id,
      title: mediaItem.title,
      description: mediaItem.extras!['description'],
      channelTitle: mediaItem.album,
      thumbnailUrl: mediaItem.artUri?.toString(),
      kind: Kind.video.name,
      channelId: null,
      playlistId: null,
      streamUrl: mediaItem.extras!['streamUrl'],
      duration: mediaItem.duration?.inMilliseconds,
      addedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        channelTitle,
        thumbnailUrl,
        kind,
        channelId,
        playlistId,
        streamUrl,
        duration,
        addedAt,
      ];
}

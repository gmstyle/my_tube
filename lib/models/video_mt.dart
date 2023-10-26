import 'package:equatable/equatable.dart';

class VideoResponseMT extends Equatable {
  final List<VideoMT> videos;
  final String? nextPageToken;

  const VideoResponseMT({required this.videos, required this.nextPageToken});

  factory VideoResponseMT.fromJson(Map<String, dynamic> json) {
    final videos = (json['videos'] as List)
        .map((e) => VideoMT.fromJson(e as Map<String, dynamic>))
        .toList();
    return VideoResponseMT(
      videos: videos,
      nextPageToken: json['nextPageToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videos': videos,
      'nextPageToken': nextPageToken,
    };
  }

  @override
  List<Object?> get props => [videos, nextPageToken];
}

class VideoMT extends Equatable {
  final String? id;
  final String? title;
  final String? description;
  final String? channelTitle;
  final String? thumbnailUrl;
  final String? kind;
  final String? channelId;
  final String? streamUrl;
  final int? duration;

  const VideoMT({
    required this.id,
    required this.title,
    required this.description,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.kind,
    required this.channelId,
    required this.streamUrl,
    required this.duration,
  });

  factory VideoMT.fromJson(Map<String, dynamic> json) {
    return VideoMT(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      channelTitle: json['channelTitle'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      kind: json['kind'] as String?,
      channelId: json['channelId'] as String?,
      streamUrl: json['streamUrl'] as String?,
      duration: json['duration'] as int?,
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
      'streamUrl': streamUrl,
      'duration': duration,
    };
  }

  VideoMT copyWith({
    String? id,
    String? title,
    String? description,
    String? channelTitle,
    String? thumbnailUrl,
    String? kind,
    String? channelId,
    String? streamUrl,
    int? duration,
  }) {
    return VideoMT(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      channelTitle: channelTitle ?? this.channelTitle,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      kind: kind ?? this.kind,
      channelId: channelId ?? this.channelId,
      streamUrl: streamUrl ?? this.streamUrl,
      duration: duration ?? this.duration,
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
        streamUrl,
        duration,
      ];
}

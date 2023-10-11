import 'package:equatable/equatable.dart';

class VideoResponseMT extends Equatable {
  final List<VideoMT> videos;
  final String nextPageToken;

  const VideoResponseMT({required this.videos, required this.nextPageToken});

  factory VideoResponseMT.fromJson(Map<String, dynamic> json) {
    final videos = (json['videos'] as List)
        .map((e) => VideoMT.fromJson(e as Map<String, dynamic>))
        .toList();
    return VideoResponseMT(
      videos: videos,
      nextPageToken: json['nextPageToken'] as String,
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
  final String? channelTitle;
  final String? thumbnailUrl;
  final String? kind;
  final String? channelId;
  final String? streamUrl;

  const VideoMT({
    required this.id,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.kind,
    required this.channelId,
    required this.streamUrl,
  });

  factory VideoMT.fromJson(Map<String, dynamic> json) {
    return VideoMT(
      id: json['id'] as String?,
      title: json['title'] as String?,
      channelTitle: json['channelTitle'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      kind: json['kind'] as String?,
      channelId: json['channelId'] as String?,
      streamUrl: json['streamUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'channelTitle': channelTitle,
      'thumbnailUrl': thumbnailUrl,
      'kind': kind,
      'channelId': channelId,
      'streamUrl': streamUrl,
    };
  }

  VideoMT copyWith({
    String? id,
    String? title,
    String? channelTitle,
    String? thumbnailUrl,
    String? kind,
    String? channelId,
    String? streamUrl,
  }) {
    return VideoMT(
      id: id ?? this.id,
      title: title ?? this.title,
      channelTitle: channelTitle ?? this.channelTitle,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      kind: kind ?? this.kind,
      channelId: channelId ?? this.channelId,
      streamUrl: streamUrl ?? this.streamUrl,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, channelTitle, thumbnailUrl, kind, channelId, streamUrl];
}

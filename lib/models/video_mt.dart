import 'package:equatable/equatable.dart';

class VideoResponse extends Equatable {
  final List<VideoMT> videos;
  final String nextPageToken;

  const VideoResponse({required this.videos, required this.nextPageToken});

  factory VideoResponse.fromJson(Map<String, dynamic> json) {
    final videos = (json['videos'] as List)
        .map((e) => VideoMT.fromJson(e as Map<String, dynamic>))
        .toList();
    return VideoResponse(
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
  final String id;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;

  const VideoMT({
    required this.id,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
  });

  factory VideoMT.fromJson(Map<String, dynamic> json) {
    return VideoMT(
      id: json['id'] as String,
      title: json['title'] as String,
      channelTitle: json['channelTitle'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'channelTitle': channelTitle,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  @override
  List<Object?> get props => [id, title, channelTitle, thumbnailUrl];
}

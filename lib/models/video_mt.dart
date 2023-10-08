import 'package:equatable/equatable.dart';

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

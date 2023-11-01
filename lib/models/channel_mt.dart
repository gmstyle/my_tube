import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';

class ChannelMT extends Equatable {
  final String? id;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? subscriberCount;
  final String? videoCount;
  final String? viewCount;
  final List<ResourceMT>? videos;

  const ChannelMT({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.subscriberCount,
    required this.videoCount,
    required this.viewCount,
    required this.videos,
  });

  factory ChannelMT.fromJson(Map<String, dynamic> json) {
    return ChannelMT(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      subscriberCount: json['subscriberCount'],
      videoCount: json['videoCount'],
      viewCount: json['viewCount'],
      videos: json['videos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'subscriberCount': subscriberCount,
      'videoCount': videoCount,
      'viewCount': viewCount,
      'videos': videos,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        thumbnailUrl,
        subscriberCount,
        videoCount,
        viewCount,
        videos,
      ];
}

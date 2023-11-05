import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';

class ChannelMT extends Equatable {
  final String? id;
  final String? title;
  final String? customUrl;
  final String? description;
  final String? thumbnailUrl;
  final String? subscriberCount;
  final String? videoCount;
  final String? viewCount;
  final List<ResourceMT>? videos;
  final List<String>? videoIds;

  const ChannelMT({
    required this.id,
    required this.title,
    required this.customUrl,
    required this.description,
    required this.thumbnailUrl,
    required this.subscriberCount,
    required this.videoCount,
    required this.viewCount,
    required this.videos,
    required this.videoIds,
  });

  factory ChannelMT.fromJson(Map<String, dynamic> json) {
    return ChannelMT(
      id: json['id'],
      title: json['title'],
      customUrl: json['customUrl'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      subscriberCount: json['subscriberCount'],
      videoCount: json['videoCount'],
      viewCount: json['viewCount'],
      videos: json['videos'],
      videoIds: json['videoIds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'customUrl': customUrl,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'subscriberCount': subscriberCount,
      'videoCount': videoCount,
      'viewCount': viewCount,
      'videos': videos,
      'videoIds': videoIds,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        customUrl,
        description,
        thumbnailUrl,
        subscriberCount,
        videoCount,
        viewCount,
        videos,
        videoIds,
      ];
}

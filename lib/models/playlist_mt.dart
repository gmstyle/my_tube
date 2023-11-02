import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';

class PlaylistMT extends Equatable {
  final String? id;
  final String? channelId;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final int? itemCount;
  final List<ResourceMT>? videos;

  const PlaylistMT({
    required this.id,
    required this.channelId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
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
      itemCount: json['itemCount'],
      videos: json['videos'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'channelId': channelId,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
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

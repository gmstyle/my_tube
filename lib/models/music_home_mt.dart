import 'package:equatable/equatable.dart';
import 'package:my_tube/models/channel_mt.dart';
import 'package:my_tube/models/playlist_mt.dart';
import 'package:my_tube/models/resource_mt.dart';

class MusicHomeMT extends Equatable {
  final String? title;
  final String? description;
  final List<ResourceMT>? carouselVideos;
  final List<SectionMT> sections;

  const MusicHomeMT({
    this.title,
    this.description,
    this.carouselVideos,
    required this.sections,
  });

  factory MusicHomeMT.fromJson(Map<String, dynamic> json) {
    return MusicHomeMT(
      title: json['title'],
      description: json['description'],
      carouselVideos: json['carouselItems'],
      sections: (json['sections'] as List<dynamic>)
          .map<SectionMT>((e) => SectionMT.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'carouselItems': carouselVideos,
      'sections': sections.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [title, description, carouselVideos, sections];
}

class SectionMT extends Equatable {
  final String? title;
  final String? playlistId;
  final List<ResourceMT>? videos;
  final List<PlaylistMT>? playlists;
  final ResourceMT? channel;

  const SectionMT({
    this.title,
    this.playlistId,
    this.videos,
    this.playlists,
    this.channel,
  });

  factory SectionMT.fromJson(Map<String, dynamic> json) {
    return SectionMT(
      title: json['title'],
      playlistId: json['playlistId'],
      videos: json['videos'],
      playlists: json['playlists'],
      channel: json['channel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'playlistId': playlistId,
      'videos': videos?.map((e) => e.toJson()).toList(),
      'playlists': playlists?.map((e) => e.toJson()).toList(),
      'channel': channel?.toJson(),
    };
  }

  @override
  List<Object?> get props => [title, playlistId, videos, playlists, channel];
}

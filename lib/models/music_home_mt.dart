import 'package:equatable/equatable.dart';
import 'package:my_tube/models/playlist_mt.dart';
import 'package:my_tube/models/resource_mt.dart';

class MusicHomeMT extends Equatable {
  final String? title;
  final String? description;
  final List<ResourceMT>? carouselVideos;
  final List<MusicSectionMT> sections;

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
          .map<MusicSectionMT>((e) => MusicSectionMT.fromJson(e))
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

class MusicSectionMT extends Equatable {
  final String? title;
  final String? playlistId;
  final List<ResourceMT>? videos;
  final List<PlaylistMT>? playlists;

  const MusicSectionMT({
    this.title,
    this.playlistId,
    this.videos,
    this.playlists,
  });

  factory MusicSectionMT.fromJson(Map<String, dynamic> json) {
    return MusicSectionMT(
      title: json['title'],
      playlistId: json['playlistId'],
      videos: json['videos'],
      playlists: json['playlists'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'playlistId': playlistId,
      'videos': videos?.map((e) => e.toJson()).toList(),
      'playlists': playlists?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [title, playlistId, videos, playlists];
}

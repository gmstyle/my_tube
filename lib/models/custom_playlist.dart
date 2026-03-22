import 'dart:convert';
import 'package:equatable/equatable.dart';

class CustomPlaylist extends Equatable {
  final String id;
  final String title;
  final List<String> videoIds;
  final DateTime createdAt;

  const CustomPlaylist({
    required this.id,
    required this.title,
    required this.videoIds,
    required this.createdAt,
  });

  CustomPlaylist copyWith({
    String? id,
    String? title,
    List<String>? videoIds,
    DateTime? createdAt,
  }) {
    return CustomPlaylist(
      id: id ?? this.id,
      title: title ?? this.title,
      videoIds: videoIds ?? this.videoIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'videoIds': videoIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory CustomPlaylist.fromMap(Map<String, dynamic> map) {
    return CustomPlaylist(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      videoIds: List<String>.from(map['videoIds'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomPlaylist.fromJson(String source) => CustomPlaylist.fromMap(json.decode(source));

  @override
  List<Object> get props => [id, title, videoIds, createdAt];
}

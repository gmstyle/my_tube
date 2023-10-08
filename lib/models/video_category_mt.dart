import 'package:equatable/equatable.dart';

class VideoCategoryMT extends Equatable {
  final String id;
  final String title;

  const VideoCategoryMT({
    required this.id,
    required this.title,
  });

  factory VideoCategoryMT.fromJson(Map<String, dynamic> json) {
    return VideoCategoryMT(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  @override
  List<Object> get props => [id, title];
}

import 'package:equatable/equatable.dart';
import 'package:my_tube/models/music_home_mt.dart';

class ChannelPageMT extends Equatable {
  final String? title;
  final String? description;
  final String? channelHandleText;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? thumbnailUrl;
  final String? tvBannerUrl;
  final List<SectionMT>? sections;
  final String? subscriberCount;
  final String? videoCount;

  const ChannelPageMT({
    this.title,
    this.description,
    this.channelHandleText,
    this.avatarUrl,
    this.bannerUrl,
    this.thumbnailUrl,
    this.tvBannerUrl,
    this.sections,
    this.subscriberCount,
    this.videoCount,
  });

  factory ChannelPageMT.fromJson(Map<String, dynamic> json) {
    return ChannelPageMT(
      title: json['title'],
      description: json['description'],
      channelHandleText: json['channelHandleText'],
      avatarUrl: json['avatarUrl'],
      bannerUrl: json['bannerUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      tvBannerUrl: json['tvBannerUrl'],
      sections:
          (json['sections'] as List<dynamic>).map<SectionMT>((e) => e).toList(),
      subscriberCount: json['viewCount'],
      videoCount: json['videoCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'channelHandleText': channelHandleText,
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'thumbnailUrl': thumbnailUrl,
      'tvBannerUrl': tvBannerUrl,
      'sections': sections?.map((e) => e.toJson()).toList(),
      'viewCount': subscriberCount,
      'videoCount': videoCount,
    };
  }

  @override
  List<Object?> get props => [
        title,
        description,
        channelHandleText,
        avatarUrl,
        bannerUrl,
        thumbnailUrl,
        tvBannerUrl,
        sections,
        subscriberCount,
        videoCount,
      ];
}

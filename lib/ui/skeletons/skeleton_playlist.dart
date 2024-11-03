import 'package:flutter/material.dart';
import 'package:my_tube/models/playlist_mt.dart';
import 'package:my_tube/utils/enums.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/resource_mt.dart';
import '../views/common/video_tile.dart';
import '../views/playlist/widgets/playlist_header.dart';

class SkeletonPlaylist extends StatelessWidget {
  const SkeletonPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            PlaylistHeader(playlist: fakeData),
            const SizedBox(height: 16),
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fakeData.videos!.length,
                itemBuilder: (context, index) {
                  final video = fakeData.videos![index];
                  return VideoTile(video: video);
                }),
          ],
        ),
      ),
    );
  }

  PlaylistMT get fakeData => PlaylistMT(
      id: 'aaaa',
      channelId: 'aaaa',
      title: BoneMock.longParagraph,
      description: BoneMock.paragraph,
      thumbnailUrl: null,
      base64Thumbnail: null,
      itemCount: '20',
      videos: List.generate(
          10,
          (index) => ResourceMT(
              id: 'aaaa',
              title: BoneMock.longParagraph,
              description: BoneMock.paragraph,
              channelTitle: BoneMock.title,
              thumbnailUrl: null,
              kind: Kind.video.name,
              channelId: 'aaaa',
              playlistId: 'aaaa',
              streamUrl: '',
              duration: 100)));
}

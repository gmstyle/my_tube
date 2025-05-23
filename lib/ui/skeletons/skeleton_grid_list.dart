import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/utils/enums.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/resource_mt.dart';
import '../views/common/video_tile.dart';

class SkeletonGridList extends StatelessWidget {
  const SkeletonGridList({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: LayoutBuilder(builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        if (isTablet) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 20,
            itemBuilder: (context, index) {
              return VideoGridItem(
                  video: ResourceMT(
                      id: 'aaaa',
                      title: BoneMock.longParagraph,
                      description: BoneMock.paragraph,
                      channelTitle: BoneMock.title,
                      thumbnailUrl: null,
                      kind: Kind.video.name,
                      channelId: 'aaaa',
                      playlistId: 'aaaa',
                      streamUrl: '',
                      duration: 100));
            },
          );
        }
        return ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return VideoTile(
                  video: ResourceMT(
                      id: 'aaaa',
                      title: BoneMock.longParagraph,
                      description: BoneMock.paragraph,
                      channelTitle: BoneMock.title,
                      thumbnailUrl: null,
                      kind: Kind.video.name,
                      channelId: 'aaaa',
                      playlistId: 'aaaa',
                      streamUrl: '',
                      duration: 100));
            });
      }),
    );
  }
}

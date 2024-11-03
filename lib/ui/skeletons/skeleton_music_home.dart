import 'package:flutter/material.dart';
import 'package:my_tube/models/music_home_mt.dart';
import 'package:my_tube/utils/enums.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/playlist_mt.dart';
import '../../models/resource_mt.dart';
import '../views/home/tabs/music_tab/widgets/carousel.dart';
import '../views/home/tabs/music_tab/widgets/playlist_section.dart';
import '../views/home/tabs/music_tab/widgets/video_section.dart';

class SkeletonMusicHhome extends StatelessWidget {
  const SkeletonMusicHhome({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
        enabled: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Carousel(carouselVideos: fakeData.carouselVideos!),
              const SizedBox(height: 16),

              // Sections
              for (final section in fakeData.sections)
                Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Text(
                              section.title ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (section.videos != null &&
                            section.videos!.isNotEmpty)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: VideoSection(
                                videos: section.videos!,
                              ),
                            ),
                          ),
                        if (section.playlists != null &&
                            section.playlists!.isNotEmpty)
                          PlaylistSection(playlists: section.playlists!),
                      ],
                    ),
                  ],
                )
            ],
          ),
        ));
  }

  MusicHomeMT get fakeData => MusicHomeMT(
        title: BoneMock.title,
        description: BoneMock.paragraph,
        carouselVideos: List.generate(5, (index) => _buildFakeVideo()),
        sections: List.generate(
          5,
          (index) => SectionMT(
            title: 'Section Title',
            videos: null,
            playlists: List.generate(
                10,
                (index) => PlaylistMT(
                    id: 'aaaa',
                    channelId: 'aaaa',
                    title: BoneMock.longParagraph,
                    description: BoneMock.paragraph,
                    thumbnailUrl: null,
                    base64Thumbnail: null,
                    itemCount: '10',
                    videos: null)),
            channels: null,
          ),
        ),
      );

  ResourceMT _buildFakeVideo() {
    return ResourceMT(
        id: 'aaaa',
        title: BoneMock.longParagraph,
        description: BoneMock.paragraph,
        channelTitle: BoneMock.title,
        thumbnailUrl: null,
        kind: Kind.video.name,
        channelId: 'aaaa',
        playlistId: 'aaaa',
        streamUrl: '',
        duration: 100);
  }
}

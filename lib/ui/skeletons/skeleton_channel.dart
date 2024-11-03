import 'package:flutter/material.dart';
import 'package:my_tube/models/channel_page_mt.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/utils/enums.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/music_home_mt.dart';
import '../../models/playlist_mt.dart';
import '../views/channel/widgets/channel_header.dart';
import '../views/home/tabs/music_tab/widgets/featured_channels_section.dart';
import '../views/home/tabs/music_tab/widgets/playlist_section.dart';
import '../views/home/tabs/music_tab/widgets/video_section.dart';

class SkeletonChannel extends StatelessWidget {
  const SkeletonChannel({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ChannelHeader(channel: fakeData),
              const SizedBox(height: 8),
              // sections
              for (final section in fakeData.sections!)
                Column(
                  children: [
                    if (section.title != null &&
                            section.title!.isNotEmpty &&
                            section.videos != null &&
                            section.videos!.isNotEmpty ||
                        section.playlists != null &&
                            section.playlists!.isNotEmpty ||
                        section.channels != null &&
                            section.channels!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              section.title ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (section.videos != null &&
                              section.videos!.isNotEmpty)
                            Row(
                              children: [
                                // add to queue
                                IconButton(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    onPressed: () {},
                                    icon: const Icon(Icons.queue_music)),
                                IconButton(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    onPressed: () {},
                                    icon: const Icon(Icons.playlist_play)),
                              ],
                            )
                        ],
                      ),
                    const SizedBox(height: 8),
                    if (section.videos != null && section.videos!.isNotEmpty)
                      VideoSection(
                        videos: section.videos!,
                        crossAxisCount: 2,
                      ),
                    if (section.playlists != null &&
                        section.playlists!.isNotEmpty)
                      PlaylistSection(playlists: section.playlists!),
                    if (section.channels != null &&
                        section.channels!.isNotEmpty)
                      FeaturedChannelsSection(channels: section.channels!),
                    const SizedBox(height: 8),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  ChannelPageMT get fakeData => ChannelPageMT(
        title: BoneMock.title,
        description: BoneMock.paragraph,
        channelHandleText: BoneMock.title,
        avatarUrl: null,
        bannerUrl: null,
        thumbnailUrl: null,
        tvBannerUrl: null,
        sections: [
          SectionMT(
            title: 'Section Title',
            videos: List.generate(20, (index) => _buildFakeVideo()),
            playlists: List.generate(
                20,
                (index) => PlaylistMT(
                    id: 'aaaa',
                    channelId: 'aaaa',
                    title: BoneMock.longParagraph,
                    description: BoneMock.paragraph,
                    thumbnailUrl: null,
                    base64Thumbnail: null,
                    itemCount: '20',
                    videos: List.generate(10, (index) => _buildFakeVideo()))),
            channels: List.generate(20, (index) => _buildFakeVideo()),
          ),
        ],
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

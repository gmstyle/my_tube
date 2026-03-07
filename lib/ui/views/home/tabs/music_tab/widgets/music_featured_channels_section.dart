import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/router/app_router.dart';

/// Sliver with a horizontal row of circular channel avatars.
class MusicFeaturedChannelsSection extends StatelessWidget {
  const MusicFeaturedChannelsSection({super.key, required this.channels});

  final List<models.ChannelTile> channels;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: channels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final channel = channels[index];
            return GestureDetector(
              onTap: () => context.pushNamed(
                AppRoute.channel.name,
                extra: {'channelId': channel.id},
              ),
              child: SizedBox(
                width: 72,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(channel.thumbnailUrl),
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(height: 6),
                    Text(
                      channel.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

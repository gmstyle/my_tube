import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/router/app_navigator.dart';
import 'package:my_tube/ui/views/common/channel_grid_item.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

/// Sliver with a horizontal row of circular channel avatars.
class MusicFeaturedChannelsSection extends StatelessWidget {
  const MusicFeaturedChannelsSection({super.key, required this.channels});

  final List<models.ChannelTile> channels;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    final width = isCompact ? 120.0 : 160.0;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: channels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final channel = channels[index];
            return GestureDetector(
              onTap: () => AppNavigator.pushChannel(context, channel.id),
              child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: width),
                  child: ChannelGridItem(channel: channel)),
            );
          },
        ),
      ),
    );
  }
}

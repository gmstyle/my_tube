import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/channel_tile.dart';

class FeaturedChannelsSection extends StatelessWidget {
  const FeaturedChannelsSection({super.key, required this.channels});

  final List<ResourceMT> channels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      child: GridView.builder(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          itemCount: channels.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisExtent: MediaQuery.of(context).size.width - 128),
          itemBuilder: (context, index) {
            final channel = channels[index];
            return GestureDetector(
              onTap: () {
                context.pushNamed(AppRoute.channel.name,
                    extra: {'channelId': channel.id});
              },
              child: ChannelTile(channel: channel),
            );
          }),
    );
  }
}

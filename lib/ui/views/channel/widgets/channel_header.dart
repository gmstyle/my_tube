import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/models/channel_page_mt.dart';
import 'package:my_tube/ui/views/common/expandable_text.dart';

class ChannelHeader extends StatelessWidget {
  const ChannelHeader({super.key, required this.channel});

  final ChannelPageMT? channel;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double size =
        screenWidth * 0.3; // Dimensione per mantenere il widget circolare
    final double minSize = 100.0; // Dimensione minima per smartphone
    final double maxSize = 200.0; // Dimensione massima per tablet

    final double avatarSize = size.clamp(minSize, maxSize);

    return Column(
      children: [
        // Channel info
        CircleAvatar(
          radius: avatarSize / 2,
          backgroundImage: channel!.avatarUrl != null
              ? CachedNetworkImageProvider(channel!.avatarUrl!)
              : null,
          child: channel!.avatarUrl == null
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              channel!.title ?? '',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (channel!.channelHandleText != null)
              Text(
                '${channel!.channelHandleText}',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            const SizedBox(height: 4),
            if (channel!.subscriberCount != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_red_eye,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Flexible(
                    child: Text(
                      ' Subscribers: ${channel!.subscriberCount!}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
          ],
        ),

        // Description
        if (channel!.description != null && channel!.description != '') ...[
          const SizedBox(height: 8),
          ExpandableText(title: 'Description', text: channel!.description ?? '')
        ],
      ],
    );
  }
}

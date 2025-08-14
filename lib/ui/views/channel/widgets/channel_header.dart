import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/common/expandable_text.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ChannelHeader extends StatelessWidget {
  const ChannelHeader({super.key, required this.channel});

  final ChannelAbout channel;

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
        ClipOval(
          child: SizedBox(
            width: avatarSize,
            height: avatarSize,
            child: Utils.buildImageWithFallback(
              thumbnailUrl: channel.thumbnails.first.url.toString(),
              context: context,
              fit: BoxFit.cover,
              placeholder: Icon(
                Icons.person,
                size: avatarSize * 0.4,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              channel.title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (channel.channelLinks.isNotEmpty)
              Text(
                '${channel.channelLinks.first.url}',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            const SizedBox(height: 4),
            if (channel.viewCount != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Views: ${channel.viewCount!}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ],
              ),
          ],
        ),

        // Description
        if (channel.description != null && channel.description != '') ...[
          const SizedBox(height: 8),
          ExpandableText(title: 'Description', text: channel.description ?? '')
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/utils/utils.dart';

class ChannelGridItem extends StatelessWidget {
  const ChannelGridItem({super.key, required this.channel});

  final ResourceMT channel;

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width *
        0.4; // Dimensione per mantenere il widget circolare

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Channel image with proper fallback handling
            channel.thumbnailUrl != null || channel.base64Thumbnail != null
                ? Utils.buildImageWithFallback(
                    thumbnailUrl: channel.thumbnailUrl,
                    base64Thumbnail: channel.base64Thumbnail,
                    context: context,
                    placeholder: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: size * 0.3,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  )
                : Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: size * 0.3,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.shadow.withValues(alpha: 0.6),
                    Theme.of(context).colorScheme.shadow.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Channel information
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (channel.title != null)
                    Text(
                      channel.title!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (channel.subscriberCount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      channel.subscriberCount!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (channel.videoCount != null &&
                      Utils.checkIfStringIsOnlyNumeric(
                          channel.videoCount!)) ...[
                    const SizedBox(height: 1),
                    Text(
                      '${channel.videoCount} videos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 9,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

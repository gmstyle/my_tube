import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/utils/utils.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

class ChannelGridItem extends StatelessWidget {
  const ChannelGridItem({super.key, required this.channel});

  final models.ChannelTile channel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = context.isCompact;
    final double size =
        MediaQuery.of(context).size.width * (isCompact ? 0.28 : 0.4);
    final borderRadius = BorderRadius.circular(isCompact ? 12 : 16);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Channel image with proper fallback handling
            Utils.buildImageWithFallback(
              thumbnailUrl: channel.thumbnailUrl,
              context: context,
              placeholder: Container(
                color: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: size * 0.3,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.shadow.withValues(alpha: 0.6),
                    theme.colorScheme.shadow.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Channel information
            Positioned(
              bottom: isCompact ? 8 : 12,
              left: 8,
              right: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    channel.title,
                    style: theme.videoTitleStyle.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: isCompact ? 13 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (channel.subscriberCount != null) ...[
                    SizedBox(height: isCompact ? 4 : 6),
                    Text(
                      channel.subscriberCount.toString(),
                      style: theme.videoSubtitleStyle.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontSize: isCompact ? 11 : 12,
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

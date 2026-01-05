import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/views/common/material_interactive_components.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

class ChannelGridItem extends StatelessWidget {
  const ChannelGridItem({
    super.key,
    required this.channel,
    this.onTap,
  });

  final models.ChannelTile channel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = context.isCompact;
    final double size =
        MediaQuery.of(context).size.width * (isCompact ? 0.28 : 0.4);
    final borderRadius = BorderRadius.circular(isCompact ? 12 : 16);

    return MaterialHoverContainer(
      borderRadius: borderRadius,
      onTap: onTap,
      // Channel items often look better with a slightly distinct background to differentiate from videos
      fillColor: theme.colorScheme.surfaceContainer,
      child: SizedBox(
        width: size,
        height: size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Prominent Avatar
            ExpressiveImage(
              borderRadius: BorderRadius.circular(size / 2), // Make it circular
              child: Container(
                width: size * 0.5,
                height: size * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Utils.buildImageWithFallback(
                    thumbnailUrl: channel.thumbnailUrl,
                    context: context,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        size: size * 0.25,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: isCompact ? 8 : 12),

            // Channel Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    channel.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (channel.subscriberCount != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      Utils.formatNumber(channel.subscriberCount!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

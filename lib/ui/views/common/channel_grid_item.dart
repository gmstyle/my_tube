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
    final borderRadius = BorderRadius.circular(isCompact ? 12 : 16);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use available width so the widget fills its grid cell exactly.
        final size = constraints.maxWidth;
        final avatarSize = size * 0.45;

        return MaterialHoverContainer(
          borderRadius: borderRadius,
          onTap: onTap,
          fillColor: theme.colorScheme.surfaceContainer,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Prominent Avatar
              ExpressiveImage(
                borderRadius: BorderRadius.circular(avatarSize / 2),
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
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
                          size: avatarSize * 0.5,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: size * 0.06),

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
        );
      },
    );
  }
}

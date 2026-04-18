import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/views/common/material_interactive_components.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/utils/utils.dart';

class ChannelGridItem extends StatefulWidget {
  const ChannelGridItem({
    super.key,
    required this.channel,
    this.onTap,
  });

  final models.ChannelTile channel;
  final VoidCallback? onTap;

  @override
  State<ChannelGridItem> createState() => _ChannelGridItemState();
}

class _ChannelGridItemState extends State<ChannelGridItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        // Use a very large radius so ClipRRect inside MaterialHoverContainer
        // produces a perfect circle for square cells.
        final borderRadius = BorderRadius.circular(size / 2);

        return MaterialHoverContainer(
          borderRadius: borderRadius,
          onTap: widget.onTap,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-bleed channel art
              AnimatedScale(
                scale: _isHovered ? 1.05 : 1.0,
                duration: AppAnimations.cardHover,
                curve: AppAnimations.cardHoverCurve,
                child: Utils.buildImageWithFallback(
                  thumbnailUrl: widget.channel.thumbnailUrl,
                  context: context,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.person,
                      size: size * 0.3,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              // Bottom gradient for text legibility
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                      Colors.black87,
                    ],
                    stops: [0.4, 0.72, 1.0],
                  ),
                ),
              ),

              // Title + subscriber count overlay
              Positioned(
                left: size * 0.06,
                right: size * 0.06,
                bottom: size * 0.1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.channel.title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.channel.subscriberCount != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        Utils.formatNumber(widget.channel.subscriberCount!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
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

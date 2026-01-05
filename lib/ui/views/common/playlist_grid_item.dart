import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/views/common/material_interactive_components.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

class PlaylistGridItem extends StatelessWidget {
  const PlaylistGridItem({
    super.key,
    required this.playlist,
    this.onTap,
  });

  final models.PlaylistTile playlist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = context.isCompact;
    final borderRadius = BorderRadius.circular(isCompact ? 12 : 16);
    final width = MediaQuery.of(context).size.width * (isCompact ? 0.46 : 0.8);

    // Stacked effect using pseudo-cards behind the main card
    return SizedBox(
      width: width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Card 2 (Bottom)
          Positioned(
            top: 4,
            child: Container(
              width: width * 0.9,
              height: width * 0.6, // Approximate height relative to width
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: borderRadius,
              ),
            ),
          ),
          // Background Card 1 (Middle)
          Positioned(
            top: 2,
            child: Container(
              width: width * 0.95,
              height: width * 0.61,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh
                    .withValues(alpha: 0.7),
                borderRadius: borderRadius,
              ),
            ),
          ),

          // Main Card (Top)
          MaterialHoverContainer(
            borderRadius: borderRadius,
            onTap: onTap,
            child: SizedBox(
              width: width,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExpressiveImage(
                    borderRadius: borderRadius,
                    child: Utils.buildImageWithFallback(
                      thumbnailUrl: playlist.thumbnailUrl,
                      context: context,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.playlist_play_rounded,
                          size: isCompact ? 32 : 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.5, 0.8, 1.0],
                      ),
                      borderRadius: borderRadius,
                    ),
                  ),

                  // Content
                  Positioned(
                    left: isCompact ? 10 : 16,
                    right: isCompact ? 10 : 16,
                    bottom: isCompact ? 10 : 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.playlist_play_rounded,
                              color: theme.colorScheme.primaryContainer,
                              size: isCompact ? 16 : 20,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                playlist.title,
                                maxLines: 2,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (playlist.videoCount != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiaryContainer
                                    .withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${playlist.videoCount} videos',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isCompact ? 10 : 11,
                                ),
                              ),
                            ),
                          ),
                        if (playlist.author != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 2),
                            child: Text(
                              playlist.author!,
                              maxLines: 1,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: isCompact ? 11 : 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

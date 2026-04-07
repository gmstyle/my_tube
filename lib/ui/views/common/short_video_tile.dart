import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/material_interactive_components.dart';
import 'package:my_tube/utils/utils.dart';

class ShortVideoTile extends StatelessWidget {
  const ShortVideoTile({
    super.key,
    required this.video,
    this.onTap,
    this.showActions = true,
  });

  final models.VideoTile video;
  final VoidCallback? onTap;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = context.buildVideoOverflowActions(
      videoId: video.id,
      videoTitle: video.title,
    );

    final content = MaterialHoverContainer(
      borderRadius: BorderRadius.circular(12),
      fillColor: Colors.transparent,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Utils.buildImageWithFallback(
              thumbnailUrl: video.thumbnailUrl,
              context: context,
              fit: BoxFit.cover,
              placeholder: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 32,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
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
                  stops: [0.45, 0.75, 1],
                ),
              ),
            ),
            if (showActions)
              Positioned(
                top: 8,
                right: 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionSurface(
                      child: EnhancedOverflowMenu(
                        actions: actions,
                        iconSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ActionSurface(
                      child: EnhancedFavoriteButton(
                        entityId: video.id,
                        entityType: FavoriteEntityType.video,
                        size: 18,
                        padding: EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (video.artist != null && video.artist!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        video.artist!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return PlayPauseGestureDetector(id: video.id, onTap: onTap, child: content);
  }
}

class _ActionSurface extends StatelessWidget {
  const _ActionSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

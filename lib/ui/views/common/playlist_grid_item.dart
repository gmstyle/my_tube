import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/utils/utils.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

class PlaylistGridItem extends StatelessWidget {
  const PlaylistGridItem({super.key, required this.playlist});

  final models.PlaylistTile playlist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = context.isCompact;
    final borderRadius = BorderRadius.circular(isCompact ? 8 : 12);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * (isCompact ? 0.46 : 0.8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Utils.buildImageWithFallback(
              thumbnailUrl: playlist.thumbnailUrl,
              context: context,
              placeholder: Container(
                color: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.playlist_play,
                  size: isCompact ? 28 : 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: Utils.getOverlayGradient(context),
              ),
            ),
            Positioned(
              left: isCompact ? 8 : 12,
              right: isCompact ? 8 : 12,
              bottom: isCompact ? 8 : 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.album_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: isCompact ? 16 : 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          playlist.title,
                          maxLines: 2,
                          style: theme.videoTitleStyle.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontSize: isCompact ? 13 : 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (playlist.author != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        playlist.author!,
                        maxLines: 1,
                        style: theme.videoSubtitleStyle.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontSize: isCompact ? 11 : 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (playlist.videoCount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${playlist.videoCount} videos',
                        style: theme.videoSubtitleStyle.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontSize: isCompact ? 10 : 11,
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
    );
  }
}

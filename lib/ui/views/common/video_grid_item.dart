import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:my_tube/ui/views/common/spectrum_playing_icon.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

class VideoGridItem extends StatelessWidget {
  const VideoGridItem({super.key, required this.video});

  final VideoTile video;

  @override
  Widget build(BuildContext context) {
    final mtPlayerService = context.watch<MtPlayerService>();
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
              thumbnailUrl: video.thumbnailUrl,
              context: context,
              placeholder: Container(
                color: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.play_circle_outline,
                  size: isCompact ? 28 : 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

            // overlay gradient
            Container(
              decoration: BoxDecoration(
                gradient: Utils.getOverlayGradient(context),
              ),
            ),

            // Title / subtitle
            Positioned(
              left: isCompact ? 8 : 12,
              right: isCompact ? 8 : 12,
              bottom: isCompact ? 8 : 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    style: theme.videoTitleStyle.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: isCompact ? 13 : 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (video.artist != null && video.artist!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        video.artist!,
                        maxLines: 1,
                        style: theme.videoSubtitleStyle.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontSize: isCompact ? 11 : 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // overlay gradient per video selected
            StreamBuilder(
                stream: mtPlayerService.mediaItem,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final currentVideoId = snapshot.data!.id;
                    if (currentVideoId == video.id) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              theme.colorScheme.shadow.withValues(alpha: 0.4),
                              theme.colorScheme.shadow.withValues(alpha: 0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox();
                }),

            // audio spectrum icon
            Positioned(
              bottom: 6,
              right: 6,
              child: SpectrumPlayingIcon(videoId: video.id),
            ),
          ],
        ),
      ),
    );
  }
}

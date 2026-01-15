import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:my_tube/ui/views/common/material_interactive_components.dart';
import 'package:my_tube/ui/views/common/spectrum_playing_icon.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:my_tube/models/tiles.dart';

import 'package:my_tube/utils/app_breakpoints.dart';

class VideoGridItem extends StatelessWidget {
  const VideoGridItem({
    super.key,
    required this.video,
  });

  final VideoTile video;

  @override
  Widget build(BuildContext context) {
    final mtPlayerService = context.watch<MtPlayerService>();
    final playerCubit = context.read<PlayerCubit>();
    final theme = Theme.of(context);
    final isCompact = context.isCompact;

    // Standard Material 3 spacing and radiuses
    final borderRadius = BorderRadius.circular(isCompact ? 12 : 16);

    return MaterialHoverContainer(
      borderRadius: borderRadius,
      onTap: () {
        // Gestione play/pause integrata
        if (mtPlayerService.currentTrack?.id != video.id) {
          playerCubit.startPlaying(video.id);
        } else {
          if (mtPlayerService.playbackState.value.playing) {
            mtPlayerService.pause();
          } else {
            mtPlayerService.play();
          }
        }
      },
      // Use Material 3 surface colors handled by the container
      child: SizedBox(
        width: MediaQuery.of(context).size.width * (isCompact ? 0.46 : 0.8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail with subtle interaction
            ExpressiveImage(
              borderRadius: borderRadius,
              child: Utils.buildImageWithFallback(
                thumbnailUrl: video.thumbnailUrl,
                context: context,
                fit: BoxFit.cover,
                placeholder: Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: isCompact ? 32 : 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            // Gradient Overlay for text legibility
            // Using standard black gradient but with opacity derived from theme if needed
            // But usually gradients for text over images need to be dark regardless of theme
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.5, 0.8, 1.0],
                ),
                borderRadius: borderRadius,
              ),
            ),

            // Active State Overlay (Playing)
            StreamBuilder(
                stream: mtPlayerService.mediaItem,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final currentVideoId = snapshot.data!.id;
                    if (currentVideoId == video.id) {
                      return Container(
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: borderRadius,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox();
                }),

            // Content Info
            Positioned(
              left: isCompact ? 10 : 16,
              right: isCompact ? 10 : 16,
              bottom: isCompact ? 10 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white, // Always white on dark gradient
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (video.artist != null && video.artist!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        video.artist!,
                        maxLines: 1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: isCompact ? 11 : 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // Spectrum Icon
            Positioned(
              top: 8,
              right: 8,
              child: SpectrumPlayingIcon(
                videoId: video.id,
                barColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

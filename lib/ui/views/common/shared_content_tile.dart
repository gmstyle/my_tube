import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/ui/views/common/spectrum_playing_icon.dart';
import 'package:my_tube/ui/views/common/material_interactive_components.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/utils/scroll_animations.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/utils/app_breakpoints.dart';

/// Lightweight DTO to unify VideoTile and MediaItem data for the shared widget.
class TileData {
  const TileData({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    this.subtitle,
    this.darkBackground = false,
  });

  final String id;
  final String title;
  final String? thumbnailUrl;
  final String? subtitle;
  final bool darkBackground;

  factory TileData.fromVideo(models.VideoTile v) => TileData(
        id: v.id,
        title: v.title,
        thumbnailUrl: v.thumbnailUrl,
        subtitle: v.artist,
      );

  factory TileData.fromMediaItem(MediaItem m) => TileData(
        id: m.id,
        title: m.title,
        thumbnailUrl: m.artUri?.toString(),
        subtitle: m.album,
        darkBackground: false,
      );
}

class SharedContentTile extends StatelessWidget {
  const SharedContentTile({
    super.key,
    required this.data,
    this.showActions = true,
    this.enableScrollAnimation = false,
    this.index = 0,
    this.onTap,
  });

  final TileData data;
  final bool showActions;
  final bool enableScrollAnimation;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    final PlayerCubit playerCubit = BlocProvider.of<PlayerCubit>(context);

    // M3: List items should be cleaner, no heavy cards by default.
    // We use MaterialHoverContainer to provide the hover/press feedback state.

    // M3: List items should be cleaner, no heavy cards by default.
    // We use MaterialHoverContainer to provide the hover/press feedback state.

    Widget tileContent = MaterialHoverContainer(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      fillColor: Colors
          .transparent, // Transparent by default, container color on hover handled by widget
      padding: EdgeInsets.all(isCompact ? 8 : 10),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align center for list look
        children: [
          // thumbnail
          _buildThumbnail(context, playerCubit, isCompact),

          SizedBox(width: isCompact ? 12 : 16),

          // content
          Expanded(child: _buildContent(context, isCompact)),

          // optional actions
          if (showActions) _buildActions(context, isCompact),
        ],
      ),
    );

    if (enableScrollAnimation) {
      return ScrollVisibilityAnimator(
        animationType: ScrollAnimationType.fadeIn,
        child: tileContent,
      );
    }

    return tileContent;
  }

  Widget _buildThumbnail(
      BuildContext context, PlayerCubit playerCubit, bool isCompact) {
    final theme = Theme.of(context);
    // 16:9 aspect ratio standard for videos
    final thumbnailWidth = isCompact ? 120.0 : 160.0;
    final thumbnailHeight = thumbnailWidth * 9 / 16;

    return SizedBox(
      width: thumbnailWidth,
      height: thumbnailHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExpressiveImage(
            borderRadius: BorderRadius.circular(8),
            child: Utils.buildImageWithFallback(
              thumbnailUrl: data.thumbnailUrl,
              context: context,
              fit: BoxFit.cover,
              placeholder: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: isCompact ? 24 : 32,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          StreamBuilder(
            stream:
                BlocProvider.of<PlayerCubit>(context).mtPlayerService.mediaItem,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final currentVideoId = snapshot.data!.id;
                if (currentVideoId == data.id) {
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          Positioned.fill(child: _buildPlayingIndicator(context, isCompact)),
        ],
      ),
    );
  }

  Widget _buildPlayingIndicator(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);
    final PlayerCubit playerCubit = BlocProvider.of<PlayerCubit>(context);

    return StreamBuilder(
      stream: playerCubit.mtPlayerService.mediaItem,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final currentVideoId = snapshot.data!.id;
          if (currentVideoId == data.id) {
            return StreamBuilder(
              stream: playerCubit.mtPlayerService.playbackState
                  .map((playbackState) => playbackState.playing)
                  .distinct(),
              builder: (context, playingSnapshot) {
                final isPlaying = playingSnapshot.data ?? false;

                return AnimatedSwitcher(
                  duration: AppAnimations.medium,
                  child: isPlaying
                      ? Center(
                          key: const ValueKey('playing'),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: AudioSpectrumIcon(
                              width: 20,
                              height: 20,
                              barColor: theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Center(
                          key: const ValueKey('paused'),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface
                                  .withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.pause,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                );
              },
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 14 : 16,
            color: data.darkBackground
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        if (data.subtitle != null && data.subtitle!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              data.subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: data.darkBackground
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                    : theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // Now playing indicator text removed as we have visual indicator on thumbnail
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isCompact) {
    final actions = context.buildVideoOverflowActions(
      videoId: data.id,
      videoTitle: data.title,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        EnhancedOverflowMenu(
          actions: actions,
          icon: Icons.more_vert,
          tooltip: 'Options',
        ),
        EnhancedFavoriteButton(
          entityId: data.id,
          entityType: FavoriteEntityType.video,
          size: isCompact ? 20.0 : 24.0,
        ),
      ],
    );
  }
}

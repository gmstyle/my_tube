import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/services/download_service.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/router/app_navigator.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/ui/views/common/material_interactive_components.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:my_tube/utils/scroll_animations.dart';
import 'package:my_tube/utils/utils.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    super.key,
    required this.playlist,
    this.index = 0,
    this.enableScrollAnimation = false,
    this.onTap,
  });

  final models.PlaylistTile playlist;
  final int index;
  final bool enableScrollAnimation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    Widget tileContent = MaterialHoverContainer(
      onTap: onTap ??
          () {
            AppNavigator.pushPlaylist(context, playlist.id);
          },
      borderRadius: BorderRadius.circular(12),
      fillColor: Colors.transparent,
      padding: EdgeInsets.all(isCompact ? 8 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Enhanced thumbnail with stack effect
          _buildThumbnail(context, isCompact),

          SizedBox(width: isCompact ? 12 : 16),

          // Enhanced content section with better typography
          Expanded(
            child: _buildContent(context, isCompact),
          ),

          // Enhanced overflow menu for secondary actions
          _buildOverflowMenu(context, isCompact),
        ],
      ),
    );

    // Apply scroll animation if enabled
    if (enableScrollAnimation) {
      return ScrollVisibilityAnimator(
        animationType: ScrollAnimationType.fadeIn,
        child: tileContent,
      );
    }

    return tileContent;
  }

  Widget _buildThumbnail(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);
    final thumbnailWidth = isCompact ? 120.0 : 160.0;
    final thumbnailHeight = thumbnailWidth * 9 / 16;

    return SizedBox(
      width: thumbnailWidth,
      height: thumbnailHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stack effect decoration
          Positioned(
            right: -4,
            top: 2,
            bottom: 2,
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ),

          ExpressiveImage(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Utils.buildImageWithFallback(
                  thumbnailUrl: playlist.thumbnailUrl,
                  context: context,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.playlist_play_rounded,
                      size: 24,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                // Video count overlay
                if (playlist.videoCount != null)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${playlist.videoCount}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enhanced title with better typography hierarchy
        Text(
          playlist.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 14 : 16,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),

        if (playlist.author != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  playlist.author!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildOverflowMenu(BuildContext context, bool isCompact) {
    final actions = _buildPlaylistOverflowActions(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        EnhancedOverflowMenu(
          actions: actions,
          icon: Icons.more_vert,
          tooltip: 'Playlist options',
        ),
        // Add favorite button for quick access
        EnhancedFavoriteButton(
          entityId: playlist.id,
          entityType: FavoriteEntityType.playlist,
          size: isCompact ? 20.0 : 24.0,
        ),
      ],
    );
  }

  List<OverflowMenuAction> _buildPlaylistOverflowActions(BuildContext context) {
    final playerCubit = context.read<PlayerCubit>();

    return [
      OverflowMenuAction(
        label: 'Play All',
        icon: Icons.play_arrow,
        onTap: () {
          playerCubit.startPlayingPlaylistById(playlist.id);
        },
      ),
      OverflowMenuAction(
        label: 'Add to Queue',
        icon: Icons.queue_music,
        onTap: () {
          playerCubit.addAllToQueueById(playlist.id);
        },
      ),
      OverflowMenuAction(
        label: 'View Playlist',
        icon: Icons.playlist_play,
        onTap: () {
          AppNavigator.pushPlaylist(context, playlist.id);
        },
      ),
      OverflowMenuAction(
        label: 'Download Playlist',
        icon: Icons.download,
        subtitle: '${playlist.videoCount} videos',
        onTap: () {
          Utils.showDownloadSelectionDialog(
            context,
            onDownloadSelected: (isAudioOnly) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Starting download for playlist: ${playlist.title}...'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );

              context.read<DownloadService>().downloadPlaylist(
                    playlistId: playlist.id,
                    playlistTitle: playlist.title,
                    context: context,
                    isAudioOnly: isAudioOnly,
                  );
            },
          );
        },
      ),
      OverflowMenuAction(
        label: 'Share Playlist',
        icon: Icons.share,
        onTap: () {
          // TODO: Implement playlist sharing
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sharing ${playlist.title}...'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    ];
  }
}

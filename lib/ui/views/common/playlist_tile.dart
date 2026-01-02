import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';
import 'package:my_tube/utils/scroll_animations.dart';
import 'package:my_tube/utils/utils.dart';

class PlaylistTile extends StatefulWidget {
  const PlaylistTile({
    super.key,
    required this.playlist,
    this.index = 0,
    this.enableScrollAnimation = false,
  });

  final models.PlaylistTile playlist;
  final int index;
  final bool enableScrollAnimation;

  @override
  State<PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: AppAnimations.cardHover,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.cardHoverScale,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: AppAnimations.cardHoverCurve,
    ));

    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.hoverElevation,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: AppAnimations.cardHoverCurve,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = context.isCompact;

    Widget tileContent = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _elevationAnimation.value,
              shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
              surfaceTintColor: theme.colorScheme.surfaceTint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 12,
                vertical: 6,
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onHover: _onHoverChanged,
                  borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
                  splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  highlightColor:
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                  child: Padding(
                    padding: EdgeInsets.all(isCompact ? 12 : 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enhanced thumbnail with better styling
                        _buildEnhancedThumbnail(context, isCompact),

                        SizedBox(width: isCompact ? 12 : 16),

                        // Enhanced content section with better typography
                        Expanded(
                          child: _buildEnhancedContent(context, isCompact),
                        ),

                        // Enhanced overflow menu for secondary actions
                        _buildEnhancedOverflowMenu(context, isCompact),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Apply scroll animation if enabled
    if (widget.enableScrollAnimation) {
      return ScrollVisibilityAnimator(
        animationType: ScrollAnimationType.fadeIn,
        child: tileContent,
      );
    }

    return tileContent;
  }

  Widget _buildEnhancedThumbnail(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);
    final thumbnailWidth = isCompact ? 100.0 : 120.0;
    final thumbnailHeight = isCompact ? 60.0 : 75.0;

    return Container(
      width: thumbnailWidth,
      height: thumbnailHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Enhanced image with better fallback
            Utils.buildImageWithFallback(
              thumbnailUrl: widget.playlist.thumbnailUrl,
              context: context,
              placeholder: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.playlist_play,
                  size: isCompact ? 24 : 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

            // Enhanced gradient overlay for better text legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    theme.colorScheme.shadow.withValues(alpha: 0.3),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Enhanced video count badge
            if (widget.playlist.videoCount != null)
              Positioned(
                top: isCompact ? 6 : 8,
                right: isCompact ? 6 : 8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 6 : 8,
                    vertical: isCompact ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.playlist_play_rounded,
                        color: theme.colorScheme.primary,
                        size: isCompact ? 12 : 14,
                      ),
                      SizedBox(width: isCompact ? 3 : 4),
                      Text(
                        '${widget.playlist.videoCount}',
                        style: theme.statsTextStyle.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: isCompact ? 10 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedContent(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enhanced title with better typography hierarchy
        Text(
          widget.playlist.title,
          style: theme.videoTitleStyle.copyWith(
            fontSize: isCompact ? 14 : 16,
            height: 1.3,
          ),
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),

        if (widget.playlist.author != null) ...[
          SizedBox(height: isCompact ? 4 : 6),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: isCompact ? 14 : 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  widget.playlist.author!,
                  style: theme.videoSubtitleStyle.copyWith(
                    fontSize: isCompact ? 12 : 13,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        // Video count info
        if (widget.playlist.videoCount != null) ...[
          SizedBox(height: isCompact ? 4 : 6),
          Row(
            children: [
              Icon(
                Icons.video_library_outlined,
                size: isCompact ? 14 : 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                _formatVideoCount(widget.playlist.videoCount!),
                style: theme.videoSubtitleStyle.copyWith(
                  fontSize: isCompact ? 11 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEnhancedOverflowMenu(BuildContext context, bool isCompact) {
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
          entityId: widget.playlist.id,
          entityType: FavoriteEntityType.playlist,
          size: isCompact ? 20.0 : 24.0,
        ),
      ],
    );
  }

  List<OverflowMenuAction> _buildPlaylistOverflowActions(BuildContext context) {
    return [
      OverflowMenuAction(
        label: 'View Playlist',
        icon: Icons.playlist_play,
        onTap: () {
          context.goNamed(AppRoute.playlist.name,
              extra: {'playlistId': widget.playlist.id});
        },
      ),
      OverflowMenuAction(
        label: 'Download All',
        icon: Icons.download,
        subtitle: '${widget.playlist.videoCount} videos',
        onTap: () {
          // TODO: Implement playlist download
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloading ${widget.playlist.title}...'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
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
              content: Text('Sharing ${widget.playlist.title}...'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    ];
  }

  String _formatVideoCount(int count) {
    if (count == 1) {
      return '1 video';
    }
    return '$count videos';
  }
}

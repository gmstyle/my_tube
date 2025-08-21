import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/spectrum_playing_icon.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:my_tube/utils/scroll_animations.dart';
import 'package:my_tube/models/tiles.dart' as models;

class VideoTile extends StatefulWidget {
  const VideoTile({
    super.key,
    required this.video,
    this.index = 0,
    this.enableScrollAnimation = false,
  });

  final models.VideoTile video;
  final int index;
  final bool enableScrollAnimation;

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile>
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
    final PlayerCubit playerCubit = BlocProvider.of<PlayerCubit>(context);
    final theme = Theme.of(context);
    final isCompact = context.isCompact;

    // Use RepaintBoundary for performance optimization
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
                        _buildEnhancedThumbnail(
                            context, playerCubit, isCompact),

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

    return PlayPauseGestureDetector(id: widget.video.id, child: tileContent);
  }

  Widget _buildEnhancedThumbnail(
    BuildContext context,
    PlayerCubit playerCubit,
    bool isCompact,
  ) {
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
              thumbnailUrl: widget.video.thumbnailUrl,
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
                  Icons.play_circle_outline,
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

            // Enhanced playing state overlay with better visibility
            StreamBuilder(
              stream: playerCubit.mtPlayerService.mediaItem,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final currentVideoId = snapshot.data!.id;
                  if (currentVideoId == widget.video.id) {
                    return Container(
                      decoration: theme.playingIndicatorDecoration.copyWith(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(isCompact ? 10 : 12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                          borderRadius:
                              BorderRadius.circular(isCompact ? 10 : 12),
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),

            // Enhanced playing indicator with improved animations
            Positioned.fill(
              child: _buildEnhancedPlayingIndicator(context, isCompact),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPlayingIndicator(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);
    final PlayerCubit playerCubit = BlocProvider.of<PlayerCubit>(context);

    return StreamBuilder(
      stream: playerCubit.mtPlayerService.mediaItem,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final currentVideoId = snapshot.data!.id;
          if (currentVideoId == widget.video.id) {
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
                            padding: EdgeInsets.all(isCompact ? 6 : 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.9),
                              borderRadius:
                                  BorderRadius.circular(isCompact ? 8 : 10),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: AudioSpectrumIcon(
                              width: isCompact ? 24 : 32,
                              height: isCompact ? 24 : 32,
                              barColor: theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Center(
                          key: const ValueKey('paused'),
                          child: Container(
                            padding: EdgeInsets.all(isCompact ? 6 : 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface
                                  .withValues(alpha: 0.9),
                              borderRadius:
                                  BorderRadius.circular(isCompact ? 8 : 10),
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.pause,
                              size: isCompact ? 16 : 20,
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

  Widget _buildEnhancedContent(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enhanced title with better typography hierarchy
        Text(
          widget.video.title,
          style: theme.videoTitleStyle.copyWith(
            fontSize: isCompact ? 14 : 16,
            height: 1.3,
          ),
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),

        if (widget.video.artist != null) ...[
          SizedBox(height: isCompact ? 4 : 6),

          // Enhanced subtitle with better styling
          Text(
            widget.video.artist!,
            style: theme.videoSubtitleStyle.copyWith(
              fontSize: isCompact ? 12 : 13,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // Add visual indicator for current playing state in text
        StreamBuilder(
          stream:
              BlocProvider.of<PlayerCubit>(context).mtPlayerService.mediaItem,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.id == widget.video.id) {
              return Padding(
                padding: EdgeInsets.only(top: isCompact ? 4 : 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.graphic_eq,
                      size: isCompact ? 12 : 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Now Playing',
                      style: theme.videoSubtitleStyle.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: isCompact ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedOverflowMenu(BuildContext context, bool isCompact) {
    final actions = context.buildVideoOverflowActions(
      videoId: widget.video.id,
      videoTitle: widget.video.title,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        EnhancedOverflowMenu(
          actions: actions,
          icon: Icons.more_vert,
          tooltip: 'Video options',
        ),
        // Add favorite button for quick access
        EnhancedFavoriteButton(
          entityId: widget.video.id,
          entityType: FavoriteEntityType.video,
          size: isCompact ? 20.0 : 24.0,
        ),
      ],
    );
  }
}

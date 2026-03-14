import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView(
      {super.key, required this.playlistId, this.hideNavBar = false});

  final String playlistId;
  final bool hideNavBar;

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  PersistentUiCubit? _uiCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _uiCubit ??= context.read<PersistentUiCubit>();
  }

  @override
  void initState() {
    super.initState();
    if (widget.hideNavBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _uiCubit?.setNavBarVisibility(false);
      });
    }
    _staggerController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
  }

  @override
  void dispose() {
    if (widget.hideNavBar) _uiCubit?.setNavBarVisibility(true);
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlaylistState state) {
    switch (state.status) {
      case PlaylistStatus.loading:
        return _buildLoadingState(context);

      case PlaylistStatus.loaded:
        return _buildLoadedState(context, state);

      case PlaylistStatus.failure:
        return _buildErrorState(context, state);

      default:
        return _buildLoadingState(context);
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    return const CustomSkeletonPlaylist();
  }

  Widget _buildLoadedState(BuildContext context, PlaylistState state) {
    final playlist = state.response!['playlist'] as Playlist;
    final videos = state.response!['videos'] as List<models.VideoTile>;
    final videoIds = videos.map((v) => v.id).toList();
    final thumbnailUrl = state.response!['thumbnailUrl'] as String?;
    final effectiveThumbnail = thumbnailUrl ?? playlist.thumbnails.highResUrl;
    final isCompact = context.isCompact;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_staggerController.isAnimating) {
        _staggerController.reset();
        _staggerController.forward();
      }
    });

    final quickVideos = videos.map<Map<String, String>>((v) {
      return {'id': v.id, 'title': v.title};
    }).toList();

    return CustomScrollView(
      slivers: [
        // ── Collapsible header ───────────────────────────────────
        SliverAppBar(
          pinned: true,
          expandedHeight: isCompact ? 220.0 : 260.0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            playlist.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            EnhancedDownloadButton(
              videos: quickVideos,
              destinationDir: playlist.title,
              showAsIcon: true,
              size: isCompact ? 20.0 : 22.0,
            ),
            EnhancedFavoriteButton(
              entityId: widget.playlistId,
              entityType: FavoriteEntityType.playlist,
              size: isCompact ? 20.0 : 22.0,
              padding: EdgeInsets.all(isCompact ? 8 : 10),
            ),
            SizedBox(width: isCompact ? 4 : 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background:
                _buildHeaderBackground(context, playlist, effectiveThumbnail),
          ),
        ),

        // ── Play All / Add to Queue row ──────────────────────────
        SliverToBoxAdapter(
          child: _buildActionRow(context, videoIds, state),
        ),

        // ── Video list ───────────────────────────────────────────
        videos.isEmpty
            ? SliverFillRemaining(
                child: _buildEmptyState(context),
              )
            : SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: _getResponsiveListPadding(context),
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final video = videos[index];
                      final quickVideo = {
                        'id': video.id,
                        'title': video.title,
                      };
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: _getResponsiveItemSpacing(context)),
                        child: _buildStaggeredVideoItem(
                            context, video, quickVideo, index),
                      );
                    },
                    childCount: videos.length,
                  ),
                ),
              ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  /// Header background: blurred thumbnail + gradient + title/metadata row
  Widget _buildHeaderBackground(
    BuildContext context,
    Playlist playlist,
    String? thumbnailUrl,
  ) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail lightly blurred as backdrop
        Transform.scale(
          scale: 1.1,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Utils.buildImageWithFallback(
              thumbnailUrl: thumbnailUrl,
              context: context,
              fit: BoxFit.cover,
              placeholder: Container(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
        // Gradient — light at top, heavier at bottom for text legibility
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 1.0],
              colors: [
                theme.colorScheme.surface.withValues(alpha: 0.05),
                theme.colorScheme.surface.withValues(alpha: 0.30),
                theme.colorScheme.surface.withValues(alpha: 0.82),
              ],
            ),
          ),
        ),
        // Metadata anchored to bottom-left
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                playlist.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.playlist_play_rounded,
                      size: 15, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${playlist.videoCount} video',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (playlist.author.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.person_outline,
                        size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        playlist.author,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Play All + Add to Queue compact row
  Widget _buildActionRow(
    BuildContext context,
    List<String> videoIds,
    PlaylistState state,
  ) {
    final playerCubit = context.read<PlayerCubit>();
    final isPlaylistLoading = state.status == PlaylistStatus.loading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, playerState) {
          final isLoading = playerState.status == PlayerStatus.loading;
          final isPlayLoading = isLoading &&
              playerState.loadingOperation == LoadingOperation.play;
          final isQueueLoading = isLoading &&
              playerState.loadingOperation == LoadingOperation.addToQueue;
          final disabled = isPlaylistLoading || isLoading;

          return Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: videoIds.isNotEmpty && !disabled
                      ? () => playerCubit.startPlayingPlaylist(videoIds)
                      : null,
                  icon: isPlayLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow, size: 18),
                  label: Text(isPlayLoading ? 'Loading...' : 'Play All'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: videoIds.isNotEmpty && !disabled
                      ? () => playerCubit.addAllToQueue(videoIds)
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isQueueLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        const Icon(Icons.queue_music, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isQueueLoading ? 'Loading...' : 'Add to Queue',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStaggeredVideoItem(
    BuildContext context,
    models.VideoTile video,
    Map<String, String> quickVideo,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        // Calculate stagger delay based on index
        // begin must be <= 1.0, so delay is clamped so that 0.4 + delay <= 1.0
        final delay = (index * 0.1).clamp(0.0, 0.6);
        final itemAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: Interval(0.4 + delay, 1.0, curve: Curves.easeOut),
        ));

        final itemSlide = Tween<double>(
          begin: 20.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: Interval(0.4 + delay, 1.0, curve: Curves.easeOut),
        ));

        return Transform.translate(
          offset: Offset(0, itemSlide.value),
          child: FadeTransition(
            opacity: itemAnimation,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              curve: AppAnimations.easeOut,
              child: VideoMenuDialog(
                quickVideo: quickVideo,
                child: VideoTile(
                  video: video,
                  index: index,
                  enableScrollAnimation: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyPlaylistState(
      onAction: () {
        context.read<PlaylistBloc>().add(
              GetPlaylist(playlistId: widget.playlistId),
            );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, PlaylistState state) {
    // Determine error type based on error message with consistent pattern
    final errorMessage = state.error ??
        'An unexpected error occurred while loading the playlist.';
    final lowerMessage = errorMessage.toLowerCase();

    // Network-related errors
    if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('timeout') ||
        lowerMessage.contains('unreachable')) {
      return NetworkErrorState(
        onRetry: () {
          context.read<PlaylistBloc>().add(
                GetPlaylist(playlistId: widget.playlistId),
              );
        },
        onGoBack: () => Navigator.of(context).pop(),
      );
    }

    // Content not found errors
    if (lowerMessage.contains('not found') ||
        lowerMessage.contains('404') ||
        lowerMessage.contains('unavailable') ||
        lowerMessage.contains('deleted')) {
      return ContentNotFoundState(
        onRetry: () {
          context.read<PlaylistBloc>().add(
                GetPlaylist(playlistId: widget.playlistId),
              );
        },
        onGoBack: () => Navigator.of(context).pop(),
      );
    }

    // Server-related errors
    if (lowerMessage.contains('server') ||
        lowerMessage.contains('500') ||
        lowerMessage.contains('503') ||
        lowerMessage.contains('502')) {
      return ServerErrorState(
        onRetry: () {
          context.read<PlaylistBloc>().add(
                GetPlaylist(playlistId: widget.playlistId),
              );
        },
        onGoBack: () => Navigator.of(context).pop(),
      );
    }

    // Generic error state with consistent styling
    return EnhancedErrorState(
      title: 'Unable to Load Playlist',
      message: errorMessage,
      onRetry: () {
        context.read<PlaylistBloc>().add(
              GetPlaylist(playlistId: widget.playlistId),
            );
      },
      onGoBack: () => Navigator.of(context).pop(),
    );
  }

  // Responsive Design Helper Methods

  /// Get responsive horizontal padding for video list
  double _getResponsiveListPadding(BuildContext context) {
    return context.selectByBreakpoint(
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
      largeDesktop: 32.0,
    );
  }

  /// Get responsive spacing between video items
  double _getResponsiveItemSpacing(BuildContext context) {
    return context.selectByBreakpoint(
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
      largeDesktop: 20.0,
    );
  }
}

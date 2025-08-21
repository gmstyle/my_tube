import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/ui/views/playlist/widgets/enhanced_playlist_header.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key, required this.playlistId});

  final String playlistId;

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainGradient(
      child: Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: Colors.transparent,
        body: BlocBuilder<PlaylistBloc, PlaylistState>(
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isCompact = context.isCompact;

    return CustomAppbar(
      showTitle: false,
      toolbarHeight: isCompact ? 56.0 : 64.0,
      actions: [
        BlocBuilder<PlaylistBloc, PlaylistState>(
          builder: (context, state) {
            if (state.status == PlaylistStatus.loaded) {
              final playlist = state.response!['playlist'] as Playlist;
              final videos =
                  state.response!['videos'] as List<models.VideoTile>;
              final quickVideos = videos.map<Map<String, String>>((video) {
                return {
                  'id': video.id,
                  'title': video.title,
                };
              }).toList();

              return AnimatedOpacity(
                opacity: 1.0,
                duration: AppAnimations.fast,
                child: _buildPlaylistActions(
                  context,
                  playlist,
                  quickVideos,
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// Build contextual actions for playlist with improved hierarchy
  Widget _buildPlaylistActions(
    BuildContext context,
    Playlist playlist,
    List<Map<String, String>> quickVideos,
  ) {
    final isCompact = context.isCompact;
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary action: Download with enhanced feedback
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surface.withValues(alpha: 0.1),
          ),
          child: EnhancedDownloadButton(
            videos: quickVideos,
            destinationDir: playlist.title,
            showAsIcon: true,
            size: isCompact ? 20.0 : 22.0,
          ),
        ),

        // Secondary action: Favorite with enhanced visual feedback
        Container(
          margin: EdgeInsets.only(left: isCompact ? 8 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surface.withValues(alpha: 0.1),
          ),
          child: EnhancedFavoriteButton(
            entityId: widget.playlistId,
            entityType: FavoriteEntityType.playlist,
            size: isCompact ? 20.0 : 22.0,
          ),
        ),
      ],
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
    final videoIds = videos.map((video) => video.id).toList();

    // Start stagger animation when content loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_staggerController.isAnimating) {
        _staggerController.reset();
        _staggerController.forward();
      }
    });

    return TweenAnimationBuilder<double>(
      duration: AppAnimations.fast,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, fadeValue, child) {
        return Opacity(
          opacity: fadeValue,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.responsiveContentMaxWidth,
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  bottom: context.responsiveVerticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Enhanced playlist header with stagger animation
                    _buildAnimatedHeader(context, playlist, videoIds),

                    // Enhanced spacing with better responsive design
                    SizedBox(height: _getResponsiveContentSpacing(context)),

                    // Video list with enhanced layout and stagger animations
                    _buildAnimatedVideoList(context, videos),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeader(
      BuildContext context, Playlist playlist, List<String> videoIds) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final headerAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        ));

        final headerSlide = Tween<double>(
          begin: 30.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        ));

        return Transform.translate(
          offset: Offset(0, headerSlide.value),
          child: FadeTransition(
            opacity: headerAnimation,
            child: EnhancedPlaylistHeader(
              playlist: playlist,
              videoIds: videoIds,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedVideoList(
      BuildContext context, List<models.VideoTile> videos) {
    if (videos.isEmpty) {
      return _buildEmptyState(context);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsiveListPadding(context),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          final quickVideo = {
            'id': video.id,
            'title': video.title,
          };

          return _buildStaggeredVideoItem(context, video, quickVideo, index);
        },
        separatorBuilder: (context, index) => SizedBox(
          height: _getResponsiveItemSpacing(context),
        ),
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
        final delay = (index * 0.1).clamp(0.0, 0.8);
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

  /// Get responsive spacing between header and content
  double _getResponsiveContentSpacing(BuildContext context) {
    return context.selectByBreakpoint(
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
      largeDesktop: 40.0,
    );
  }

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

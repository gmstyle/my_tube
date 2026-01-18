import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/channel/widgets/enhanced_channel_header.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ChannelView extends StatefulWidget {
  const ChannelView({super.key, required this.channelId});

  final String channelId;

  @override
  State<ChannelView> createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView>
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
    return Scaffold(
      appBar: _buildEnhancedAppBar(context),
      body: BlocBuilder<ChannelPageBloc, ChannelPageState>(
        builder: (context, state) {
          return _buildStateContent(context, state);
        },
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, ChannelPageState state) {
    switch (state.status) {
      case ChannelPageStatus.loading:
        return _buildEnhancedLoadingState(context);

      case ChannelPageStatus.loaded:
        return _buildLoadedContent(context, state);

      case ChannelPageStatus.failure:
        return _buildEnhancedErrorState(context, state);

      default:
        return _buildEnhancedLoadingState(context);
    }
  }

  /// Enhanced app bar with improved contextual actions and icon hierarchy
  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    final isCompact = context.isCompact;

    return CustomAppbar(
      showTitle: false,
      toolbarHeight: isCompact ? 56.0 : 64.0,
      actions: [
        BlocBuilder<ChannelPageBloc, ChannelPageState>(
          builder: (context, state) {
            if (state.status == ChannelPageStatus.loaded) {
              final channel = state.data?['channel'] as Channel;
              final rawItems = state.items;
              final videos = rawItems != null
                  ? List<models.VideoTile>.from(
                      rawItems.map((e) => e as models.VideoTile))
                  : <models.VideoTile>[];

              return _buildChannelActions(context, channel, videos);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// Build contextual actions for channel with improved icon hierarchy
  Widget _buildChannelActions(
    BuildContext context,
    Channel channel,
    List<models.VideoTile> videos,
  ) {
    final isCompact = context.isCompact;
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tertiary action: Favorite with enhanced visual feedback
        Container(
          margin: EdgeInsets.only(left: isCompact ? 6 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surface.withValues(alpha: 0.1),
          ),
          child: EnhancedFavoriteButton(
            entityId: channel.id.value,
            entityType: FavoriteEntityType.channel,
            size: isCompact ? 20.0 : 22.0,
            padding: EdgeInsets.all(isCompact ? 8 : 10),
          ),
        ),

        // Secondary action: Overflow menu with enhanced visual feedback
        Container(
          margin: EdgeInsets.only(left: isCompact ? 6 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surface.withValues(alpha: 0.1),
          ),
          child: EnhancedOverflowMenu(
            actions: _buildChannelOverflowActions(context, channel, videos),
            tooltip: 'More options',
            iconSize: isCompact ? 20.0 : 22.0,
            padding: EdgeInsets.all(isCompact ? 8 : 10),
          ),
        ),
      ],
    );
  }

  /// Enhanced loading state with improved skeleton
  Widget _buildEnhancedLoadingState(BuildContext context) {
    return const CustomSkeletonChannel();
  }

  /// Enhanced error state with recovery actions and consistent pattern
  Widget _buildEnhancedErrorState(
      BuildContext context, ChannelPageState state) {
    // Determine error type based on error message with consistent pattern
    final errorMessage = state.error ??
        'An unexpected error occurred while loading the channel.';
    final lowerMessage = errorMessage.toLowerCase();

    // Network-related errors
    if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('timeout') ||
        lowerMessage.contains('unreachable')) {
      return NetworkErrorState(
        onRetry: () {
          context.read<ChannelPageBloc>().add(
                GetChannelDetails(channelId: widget.channelId),
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
          context.read<ChannelPageBloc>().add(
                GetChannelDetails(channelId: widget.channelId),
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
          context.read<ChannelPageBloc>().add(
                GetChannelDetails(channelId: widget.channelId),
              );
        },
        onGoBack: () => Navigator.of(context).pop(),
      );
    }

    // Generic error state with consistent styling
    return EnhancedErrorState(
      title: 'Failed to Load Channel',
      message: errorMessage,
      onRetry: () {
        context.read<ChannelPageBloc>().add(
              GetChannelDetails(channelId: widget.channelId),
            );
      },
      onGoBack: () => Navigator.of(context).pop(),
    );
  }

  /// Enhanced loaded content with improved layout structure
  Widget _buildLoadedContent(BuildContext context, ChannelPageState state) {
    final channel = state.data?['channel'] as Channel;
    final rawItems = state.items;
    final videos = rawItems != null
        ? List<models.VideoTile>.from(
            rawItems.map((e) => e as models.VideoTile))
        : <models.VideoTile>[];
    final ids = videos.map((video) => video.id).toList();

    // Start stagger animation when content loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_staggerController.isAnimating) {
        _staggerController.reset();
        _staggerController.forward();
      }
    });

    if (videos.isEmpty) {
      return _buildEmptyState(context, channel);
    }

    return TweenAnimationBuilder<double>(
      duration: AppAnimations.fast,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, fadeValue, child) {
        return Opacity(
          opacity: fadeValue,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.vertical) {
                final maxScroll = notification.metrics.maxScrollExtent;
                final current = notification.metrics.pixels;
                if (maxScroll - current < 300) {
                  context
                      .read<ChannelPageBloc>()
                      .add(const LoadMoreChannelVideos());
                }
              }
              return false;
            },
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.responsiveContentMaxWidth,
                ),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Enhanced header with stagger animation
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAnimatedHeader(context, channel, ids),
                          SizedBox(
                              height: _getResponsiveContentSpacing(context)),
                        ],
                      ),
                    ),
                    // Enhanced video list with stagger animations
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _getResponsiveListPadding(context),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= videos.length) {
                              return _buildEnhancedListLoader(context);
                            }
                            final video = videos[index];
                            final quickVideo = {
                              'id': video.id,
                              'title': video.title,
                            };
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: _getResponsiveItemSpacing(context),
                              ),
                              child: _buildStaggeredVideoItem(
                                  context, video, quickVideo, index),
                            );
                          },
                          childCount:
                              videos.length + (state.isLoadingMore ? 1 : 0),
                        ),
                      ),
                    ),
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
      BuildContext context, Channel channel, List<String> videoIds) {
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
            child: EnhancedChannelHeader(
              channel: channel,
              videoIds: videoIds,
            ),
          ),
        );
      },
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
            child: VideoMenuDialog(
              quickVideo: quickVideo,
              child: VideoTile(
                video: video,
                index: index,
                enableScrollAnimation: true,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Enhanced empty state for channels with no videos
  Widget _buildEmptyState(BuildContext context, Channel channel) {
    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: context.responsiveContentMaxWidth,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show channel header even when empty
              EnhancedChannelHeader(
                channel: channel,
                videoIds: const [],
              ),
              const SizedBox(height: 48),
              EmptyChannelState(
                onAction: () {
                  context.read<ChannelPageBloc>().add(
                        GetChannelDetails(channelId: channel.id.value),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build channel-specific overflow actions
  List<OverflowMenuAction> _buildChannelOverflowActions(
    BuildContext context,
    Channel channel,
    List<models.VideoTile> videos,
  ) {
    final videoData = videos
        .map((v) => {
              'id': v.id,
              'title': v.title,
            })
        .toList();

    return [
      if (videos.isNotEmpty) ...[
        OverflowMenuAction(
          label: 'Download All Videos',
          icon: Icons.download,
          subtitle: '${videos.length} videos',
          onTap: () => _showDownloadAllDialog(context, videoData),
        ),
        OverflowMenuAction(
          label: 'Download All Audio',
          icon: Icons.music_note,
          subtitle: 'Audio only',
          onTap: () =>
              _showDownloadAllDialog(context, videoData, isAudioOnly: true),
        ),
      ],
      OverflowMenuAction(
        label: 'Share Channel',
        icon: Icons.share,
        onTap: () => _shareChannel(context, channel),
      ),
    ];
  }

  /// Show download all dialog
  void _showDownloadAllDialog(
    BuildContext context,
    List<Map<String, String>> videos, {
    bool isAudioOnly = false,
  }) {
    final theme = Theme.of(context);
    final type = isAudioOnly ? 'audio tracks' : 'videos';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download All ${isAudioOnly ? 'Audio' : 'Videos'}'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Text(
          'This will download ${videos.length} $type from this channel. This may take a while and use significant storage space.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement bulk download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Starting download of ${videos.length} $type...'),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  /// Share channel functionality
  void _shareChannel(BuildContext context, Channel channel) {
    // TODO: Implement channel sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${channel.title}...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Enhanced list loader for pagination
  Widget _buildEnhancedListLoader(BuildContext context) {
    return const LoadingMoreIndicator(
      message: 'Loading more videos...',
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

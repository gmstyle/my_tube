import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/ui/views/common/playlist_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:my_tube/utils/utils.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ChannelView extends StatefulWidget {
  const ChannelView({super.key, required this.channelId});

  final String channelId;

  @override
  State<ChannelView> createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView>
    with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final bloc = context.read<ChannelPageBloc>();
    final state = bloc.state;
    if (state.status != ChannelPageStatus.loaded) return;
    final channel = state.data?['channel'] as Channel?;
    if (channel == null) return;

    switch (_tabController.index) {
      case 1:
        // Lazy-load shorts on first visit
        if (state.shorts == null && !state.isLoadingShorts) {
          bloc.add(LoadChannelShorts(channelId: channel.id.value));
        }
      case 2:
        // Lazy-load playlists on first visit
        if (state.playlists == null && !state.isLoadingPlaylists) {
          bloc.add(LoadChannelPlaylists(channelTitle: channel.title));
        }
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  /// Enhanced loading state with improved skeleton
  Widget _buildEnhancedLoadingState(BuildContext context) {
    return const CustomSkeletonChannel();
  }

  /// Enhanced error state with recovery actions and consistent pattern
  Widget _buildEnhancedErrorState(
      BuildContext context, ChannelPageState state) {
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

  /// Main loaded content — tabbed layout: Videos | Shorts | Playlists
  Widget _buildLoadedContent(BuildContext context, ChannelPageState state) {
    final channel = state.data?['channel'] as Channel;
    final rawItems = state.items;
    final videos = rawItems != null
        ? List<models.VideoTile>.from(
            rawItems.map((e) => e as models.VideoTile))
        : <models.VideoTile>[];
    final ids = videos.map((v) => v.id).toList();

    // Trigger stagger animation on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_staggerController.isAnimating) {
        _staggerController.reset();
        _staggerController.forward();
      }
    });

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // ── Collapsible channel SliverAppBar ──
        _buildChannelSliverAppBar(
            context, channel, ids, videos, innerBoxIsScrolled),
        // ── Pinned TabBar ──
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Videos'),
                Tab(text: 'Shorts'),
                Tab(text: 'Playlists'),
              ],
            ),
            Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 0: Videos ──
          _buildVideosTab(context, state, videos, ids),
          // ── Tab 1: Shorts ──
          _buildShortsTab(context, state),
          // ── Tab 2: Playlists ──
          _buildPlaylistsTab(context, state),
        ],
      ),
    );
  }

  /// Collapsible SliverAppBar with blurred background, avatar and channel info
  Widget _buildChannelSliverAppBar(
    BuildContext context,
    Channel channel,
    List<String> ids,
    List<models.VideoTile> videos,
    bool innerBoxIsScrolled,
  ) {
    final theme = Theme.of(context);
    final isCompact = context.isCompact;

    return SliverAppBar(
      pinned: true,
      expandedHeight: isCompact ? 160.0 : 200.0,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: theme.colorScheme.surface,
      title: Text(
        channel.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        EnhancedFavoriteButton(
          entityId: channel.id.value,
          entityType: FavoriteEntityType.channel,
          size: isCompact ? 20.0 : 22.0,
          padding: EdgeInsets.all(isCompact ? 8 : 10),
        ),
        EnhancedOverflowMenu(
          actions: _buildChannelOverflowActions(context, channel, videos),
          tooltip: 'More options',
          iconSize: isCompact ? 20.0 : 22.0,
          padding: EdgeInsets.all(isCompact ? 8 : 10),
        ),
        SizedBox(width: isCompact ? 4 : 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _buildHeaderBackground(context, channel, theme, isCompact),
      ),
    );
  }

  /// Header background: blurred avatar backdrop + gradient + avatar + info row
  Widget _buildHeaderBackground(
    BuildContext context,
    Channel channel,
    ThemeData theme,
    bool isCompact,
  ) {
    final avatarSize = isCompact ? 64.0 : 80.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Logo as atmospheric backdrop — lightly blurred, clearly visible
        Transform.scale(
          scale: 1.1,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Utils.buildImageWithFallback(
              thumbnailUrl: channel.logoUrl,
              context: context,
              fit: BoxFit.cover,
              placeholder: Container(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
        // Thin gradient at the bottom only — keeps text readable, logo fully visible
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
        // Avatar + channel info anchored to bottom
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Utils.buildImageWithFallback(
                    thumbnailUrl: channel.logoUrl,
                    context: context,
                    fit: BoxFit.cover,
                    placeholder: Icon(
                      Icons.person,
                      size: avatarSize * 0.45,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      channel.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (channel.subscribersCount != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${Utils.formatNumber(channel.subscribersCount!)} subscribers',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Compact Play All / Add to Queue row below the collapsible header
  Widget _buildChannelActionRow(BuildContext context, List<String> ids) {
    final playerCubit = context.read<PlayerCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, playerState) {
          final isLoading = playerState.status == PlayerStatus.loading;
          final isPlayLoading = isLoading &&
              playerState.loadingOperation == LoadingOperation.play;
          final isQueueLoading = isLoading &&
              playerState.loadingOperation == LoadingOperation.addToQueue;

          return Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: ids.isNotEmpty && !isLoading
                      ? () => playerCubit.startPlayingPlaylist(ids)
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
                  onPressed: ids.isNotEmpty && !isLoading
                      ? () => playerCubit.addAllToQueue(ids)
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

  // ─── Tab 0: Videos ────────────────────────────────────────────────────────

  Widget _buildVideosTab(
    BuildContext context,
    ChannelPageState state,
    List<models.VideoTile> videos,
    List<String> ids,
  ) {
    if (videos.isEmpty) {
      return _buildEmptyTabContent(context, 'No videos found for this channel');
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          final maxScroll = notification.metrics.maxScrollExtent;
          final current = notification.metrics.pixels;
          if (maxScroll - current < 300) {
            context.read<ChannelPageBloc>().add(const LoadMoreChannelVideos());
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
            slivers: [
              SliverToBoxAdapter(
                child: _buildChannelActionRow(context, ids),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: _getResponsiveListPadding(context),
                  vertical: 8,
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
                    childCount: videos.length + (state.isLoadingMore ? 1 : 0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tab 1: Shorts ────────────────────────────────────────────────────────

  Widget _buildShortsTab(BuildContext context, ChannelPageState state) {
    if (state.isLoadingShorts) {
      return const Center(child: CircularProgressIndicator());
    }

    final shorts = state.shorts != null
        ? List<models.VideoTile>.from(
            state.shorts!.map((e) => e as models.VideoTile))
        : null;

    if (shorts == null) {
      // Not yet loaded — show a placeholder message since tab listener handles loading
      return const Center(child: CircularProgressIndicator());
    }

    if (shorts.isEmpty) {
      return _buildEmptyTabContent(context, 'No shorts found for this channel');
    }

    final crossAxisCount = context.isCompact ? 2 : 3;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          final maxScroll = notification.metrics.maxScrollExtent;
          final current = notification.metrics.pixels;
          if (maxScroll - current < 300) {
            context.read<ChannelPageBloc>().add(const LoadMoreChannelShorts());
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
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(_getResponsiveListPadding(context)),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: _getResponsiveItemSpacing(context),
                    mainAxisSpacing: _getResponsiveItemSpacing(context),
                    childAspectRatio: 9 / 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final short = shorts[index];
                      final quickVideo = {
                        'id': short.id,
                        'title': short.title,
                      };
                      return VideoMenuDialog(
                        quickVideo: quickVideo,
                        child: VideoTile(
                          video: short,
                          index: index,
                          enableScrollAnimation: false,
                        ),
                      );
                    },
                    childCount: shorts.length,
                  ),
                ),
              ),
              if (state.isLoadingMoreShorts)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tab 2: Playlists ─────────────────────────────────────────────────────

  Widget _buildPlaylistsTab(BuildContext context, ChannelPageState state) {
    if (state.isLoadingPlaylists) {
      return const Center(child: CircularProgressIndicator());
    }

    final playlists = state.playlists != null
        ? List<models.PlaylistTile>.from(
            state.playlists!.map((e) => e as models.PlaylistTile))
        : null;

    if (playlists == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (playlists.isEmpty) {
      return _buildEmptyTabContent(
          context, 'No playlists found for this channel');
    }

    final crossAxisCount = context.isCompact ? 2 : 3;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          final maxScroll = notification.metrics.maxScrollExtent;
          final current = notification.metrics.pixels;
          if (maxScroll - current < 300) {
            context
                .read<ChannelPageBloc>()
                .add(const LoadMoreChannelPlaylists());
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
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(_getResponsiveListPadding(context)),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: _getResponsiveItemSpacing(context),
                    mainAxisSpacing: _getResponsiveItemSpacing(context),
                    childAspectRatio: 16 / 13,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final playlist = playlists[index];
                      return PlaylistGridItem(
                        playlist: playlist,
                        onTap: () => context.pushNamed(
                          AppRoute.playlist.name,
                          extra: {'playlistId': playlist.id},
                        ),
                      );
                    },
                    childCount: playlists.length,
                  ),
                ),
              ),
              if (state.isLoadingMorePlaylists)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────

  Widget _buildEmptyTabContent(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
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
        final delay = (index * 0.1).clamp(0.0, 0.8);
        final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(0.4 + delay, 1.0, curve: Curves.easeOut),
          ),
        );
        final itemSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(0.4 + delay, 1.0, curve: Curves.easeOut),
          ),
        );
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

  Widget _buildEnhancedListLoader(BuildContext context) {
    return const LoadingMoreIndicator(
      message: 'Loading more videos...',
    );
  }

  /// Build channel-specific overflow actions
  List<OverflowMenuAction> _buildChannelOverflowActions(
    BuildContext context,
    Channel channel,
    List<models.VideoTile> videos,
  ) {
    final videoData =
        videos.map((v) => {'id': v.id, 'title': v.title}).toList();

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          'This will download ${videos.length} $type from this channel.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
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

  void _shareChannel(BuildContext context, Channel channel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${channel.title}...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  // Responsive helpers
  double _getResponsiveListPadding(BuildContext context) =>
      context.selectByBreakpoint(
        mobile: 16.0,
        tablet: 20.0,
        desktop: 24.0,
        largeDesktop: 32.0,
      );

  double _getResponsiveItemSpacing(BuildContext context) =>
      context.selectByBreakpoint(
        mobile: 8.0,
        tablet: 12.0,
        desktop: 16.0,
        largeDesktop: 20.0,
      );
}

// ─── SliverPersistentHeaderDelegate for the TabBar ───────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _backgroundColor;

  _TabBarDelegate(this._tabBar, this._backgroundColor);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(color: _backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      _tabBar != oldDelegate._tabBar ||
      _backgroundColor != oldDelegate._backgroundColor;
}

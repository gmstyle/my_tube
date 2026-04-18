import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/router/app_navigator.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/ui/views/common/playlist_grid_item.dart';
import 'package:my_tube/ui/views/common/short_video_tile.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/utils/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Tablet layout for the channel view.
/// Receives pre-resolved data + animation/tab controllers from [ChannelView].
class ChannelTabletLayout extends StatelessWidget {
  const ChannelTabletLayout({
    super.key,
    required this.channelId,
    required this.channel,
    required this.videos,
    required this.ids,
    required this.state,
    required this.staggerController,
    required this.tabController,
  });

  final String channelId;
  final Channel channel;
  final List<models.VideoTile> videos;
  final List<String> ids;
  final ChannelPageState state;
  final AnimationController staggerController;
  final TabController tabController;

  // ── Tablet-specific constants ─────────────────────────────────────────────
  static const double _listPadding = 20.0;
  static const double _itemSpacing = 12.0;
  static const double _expandedHeight = 260.0;
  static const double _iconSize = 22.0;
  static const int _crossAxisCount = 3;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildSliverAppBar(context, innerBoxIsScrolled),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: 'Videos'),
                Tab(text: 'Playlists'),
                Tab(text: 'Shorts'),
              ],
            ),
            Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
      body: TabBarView(
        controller: tabController,
        children: [
          _buildVideosTab(context),
          _buildPlaylistsTab(context),
          _buildShortsTab(context),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context, bool innerBoxIsScrolled) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      expandedHeight: _expandedHeight,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: theme.colorScheme.surface,
      title: Text(
        channel.title,
        style:
            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      actions: [
        EnhancedFavoriteButton(
          entityId: channel.id.value,
          entityType: FavoriteEntityType.channel,
          size: _iconSize,
          padding: const EdgeInsets.all(8),
        ),
        EnhancedOverflowMenu(
          actions: _buildOverflowActions(context),
          tooltip: 'More options',
          iconSize: _iconSize,
          padding: const EdgeInsets.all(8),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _buildHeaderBackground(context, theme),
      ),
    );
  }

  Widget _buildHeaderBackground(BuildContext context, ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred background fill
        Transform.scale(
          scale: 1.1,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Utils.buildImageWithFallback(
              thumbnailUrl: channel.logoUrl,
              context: context,
              fit: BoxFit.cover,
              placeholder:
                  Container(color: theme.colorScheme.surfaceContainerHighest),
            ),
          ),
        ),
        // Semi-transparent overlay for contrast
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.75),
          ),
        ),
        // Side-by-side content (below toolbar)
        Positioned(
          top: kToolbarHeight,
          left: _listPadding,
          right: _listPadding,
          bottom: 12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left: channel art (square) ──────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Utils.buildImageWithFallback(
                    thumbnailUrl: channel.logoUrl,
                    context: context,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // ── Right: title, subscribers, description, buttons ─────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      channel.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (channel.subscribersCount != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.people_outline,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${Utils.formatNumber(channel.subscribersCount!)} subscribers',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildHeaderActionButtons(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Header action buttons ─────────────────────────────────────────────────

  Widget _buildHeaderActionButtons(BuildContext context) {
    final playerCubit = context.read<PlayerCubit>();
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, playerState) {
        final isLoading = playerState.status == PlayerStatus.loading;
        final isPlayLoading =
            isLoading && playerState.loadingOperation == LoadingOperation.play;
        final isQueueLoading = isLoading &&
            playerState.loadingOperation == LoadingOperation.addToQueue;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: ids.isNotEmpty && !isLoading
                  ? () => playerCubit.startPlayingPlaylist(ids)
                  : null,
              icon: isPlayLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.play_arrow, size: 20),
              label: Text(isPlayLoading ? 'Loading...' : 'Play All'),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(
              onPressed: ids.isNotEmpty && !isLoading
                  ? () => playerCubit.addAllToQueue(ids)
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isQueueLoading)
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    const Icon(Icons.queue_music, size: 20),
                  const SizedBox(width: 8),
                  Text(isQueueLoading ? 'Loading...' : 'Add to Queue'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────

  Widget _buildVideosTab(BuildContext context) {
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
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(_listPadding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
                crossAxisSpacing: _itemSpacing,
                mainAxisSpacing: _itemSpacing,
                childAspectRatio: 16 / 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final video = videos[index];
                  final quickVideo = {'id': video.id, 'title': video.title};
                  return VideoMenuDialog(
                    quickVideo: quickVideo,
                    child: VideoGridItem(video: video),
                  );
                },
                childCount: videos.length,
              ),
            ),
          ),
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildShortsTab(BuildContext context) {
    if (state.isLoadingShorts) {
      return const Center(child: CircularProgressIndicator());
    }
    final shorts = state.shorts != null
        ? List<models.VideoTile>.from(
            state.shorts!.map((e) => e as models.VideoTile))
        : null;
    if (shorts == null) return const Center(child: CircularProgressIndicator());
    if (shorts.isEmpty) {
      return _buildEmptyTabContent(context, 'No shorts found for this channel');
    }

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
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(_listPadding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
                crossAxisSpacing: _itemSpacing,
                mainAxisSpacing: _itemSpacing,
                childAspectRatio: 9 / 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final short = shorts[index];
                  final quickVideo = {'id': short.id, 'title': short.title};
                  return VideoMenuDialog(
                      quickVideo: quickVideo,
                      child: ShortVideoTile(video: short));
                },
                childCount: shorts.length,
              ),
            ),
          ),
          if (state.isLoadingMoreShorts)
            const SliverToBoxAdapter(
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator())),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab(BuildContext context) {
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
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(_listPadding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
                crossAxisSpacing: _itemSpacing,
                mainAxisSpacing: _itemSpacing,
                childAspectRatio: 16 / 13,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final playlist = playlists[index];
                  return PlaylistGridItem(
                    playlist: playlist,
                    onTap: () =>
                        AppNavigator.pushPlaylist(context, playlist.id),
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
                  child: Center(child: CircularProgressIndicator())),
            ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildEmptyTabContent(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
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

  List<OverflowMenuAction> _buildOverflowActions(BuildContext context) {
    final videoData =
        videos.map((v) => {'id': v.id, 'title': v.title}).toList();
    return [
      if (videos.isNotEmpty) ...[
        OverflowMenuAction(
          label: 'Download All Videos',
          icon: Icons.download,
          subtitle: '${videos.length} videos',
          onTap: () => _showDownloadDialog(context, videoData),
        ),
        OverflowMenuAction(
          label: 'Download All Audio',
          icon: Icons.music_note,
          subtitle: 'Audio only',
          onTap: () =>
              _showDownloadDialog(context, videoData, isAudioOnly: true),
        ),
      ],
      OverflowMenuAction(
        label: 'Share Channel',
        icon: Icons.share,
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sharing ${channel.title}...'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    ];
  }

  void _showDownloadDialog(
    BuildContext context,
    List<Map<String, String>> videoData, {
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
            'This will download ${videoData.length} $type from this channel.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Starting download of ${videoData.length} $type...'),
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
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this._tabBar, this._backgroundColor);
  final TabBar _tabBar;
  final Color _backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      ColoredBox(color: _backgroundColor, child: _tabBar);

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

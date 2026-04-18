import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Tablet layout for the playlist view.
class PlaylistTabletLayout extends StatelessWidget {
  const PlaylistTabletLayout({
    super.key,
    required this.playlistId,
    required this.playlist,
    required this.videos,
    required this.videoIds,
    required this.thumbnailUrl,
    required this.state,
    required this.staggerController,
  });

  final String playlistId;
  final Playlist playlist;
  final List<models.VideoTile> videos;
  final List<String> videoIds;
  final String? thumbnailUrl;
  final PlaylistState state;
  final AnimationController staggerController;

  // ── Tablet-specific constants ─────────────────────────────────────────────
  static const double _expandedHeight = 300.0;
  static const double _listPadding = 20.0;
  static const double _itemSpacing = 12.0;
  static const double _iconSize = 22.0;
  static const int _crossAxisCount = 3;

  @override
  Widget build(BuildContext context) {
    final quickVideos = videos.map<Map<String, String>>((v) {
      return {'id': v.id, 'title': v.title};
    }).toList();

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, quickVideos),
        videos.isEmpty
            ? const SliverFillRemaining(child: _EmptyPlaylistBody())
            : SliverPadding(
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
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(
      BuildContext context, List<Map<String, String>> quickVideos) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: _expandedHeight,
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
          size: _iconSize,
        ),
        EnhancedFavoriteButton(
          entityId: playlistId,
          entityType: FavoriteEntityType.playlist,
          size: _iconSize,
          padding: const EdgeInsets.all(10),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _buildHeaderBackground(context),
      ),
    );
  }

  Widget _buildHeaderBackground(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred background fill
        Transform.scale(
          scale: 1.1,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Utils.buildImageWithFallback(
              thumbnailUrl: thumbnailUrl,
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
              // ── Left: playlist thumbnail (square) ──────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Utils.buildImageWithFallback(
                    thumbnailUrl: thumbnailUrl,
                    context: context,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.queue_music_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // ── Right: title, meta, buttons ────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      playlist.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
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
                            size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${playlist.videoCount} video',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (playlist.author.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.person_outline,
                              size: 15,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              playlist.author,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
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
    final isPlaylistLoading = state.status == PlaylistStatus.loading;
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, playerState) {
        final isLoading = playerState.status == PlayerStatus.loading;
        final isPlayLoading =
            isLoading && playerState.loadingOperation == LoadingOperation.play;
        final isQueueLoading = isLoading &&
            playerState.loadingOperation == LoadingOperation.addToQueue;
        final disabled = isPlaylistLoading || isLoading;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: videoIds.isNotEmpty && !disabled
                  ? () => playerCubit.startPlayingPlaylist(videoIds)
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
              onPressed: videoIds.isNotEmpty && !disabled
                  ? () => playerCubit.addAllToQueue(videoIds)
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
}

class _EmptyPlaylistBody extends StatelessWidget {
  const _EmptyPlaylistBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.queue_music_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'This playlist is empty',
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
}

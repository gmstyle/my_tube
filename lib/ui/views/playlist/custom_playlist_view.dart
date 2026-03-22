import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/custom_playlists/custom_playlists_cubit.dart';
import 'package:my_tube/blocs/custom_playlists/custom_playlists_state.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/custom_playlist.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class CustomPlaylistView extends StatefulWidget {
  final CustomPlaylist initialPlaylist;

  const CustomPlaylistView({super.key, required this.initialPlaylist});

  @override
  State<CustomPlaylistView> createState() => _CustomPlaylistViewState();
}

class _CustomPlaylistViewState extends State<CustomPlaylistView> {
  bool _isLoading = true;
  List<models.VideoTile?> _cachedVideos = [];
  // track the last loaded IDs to avoid unnecessary re-fetches
  List<String> _loadedIds = [];

  @override
  void initState() {
    super.initState();
    _loadMetadata(widget.initialPlaylist);
  }

  Future<void> _loadMetadata(CustomPlaylist playlist) async {
    if (_loadedIds == playlist.videoIds) return;
    setState(() => _isLoading = true);
    final repo = context.read<YoutubeExplodeRepository>();
    final futures = playlist.videoIds.map((id) async {
      try {
        return await repo.getVideoMetadata(id);
      } catch (e) {
        return null;
      }
    });

    final results = await Future.wait(futures);
    if (mounted) {
      setState(() {
        _cachedVideos = results;
        _loadedIds = List<String>.from(playlist.videoIds);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomPlaylistsCubit, CustomPlaylistsState>(
      listener: (context, state) {
        final currentPlaylist = state.playlists.cast<CustomPlaylist?>().firstWhere(
              (p) => p?.id == widget.initialPlaylist.id,
              orElse: () => null,
            );
        if (currentPlaylist != null &&
            currentPlaylist.videoIds.join() != _loadedIds.join()) {
          _loadMetadata(currentPlaylist);
        }
      },
      builder: (context, state) {
        final currentPlaylist = state.playlists
            .cast<CustomPlaylist?>()
            .firstWhere(
              (p) => p?.id == widget.initialPlaylist.id,
              orElse: () => widget.initialPlaylist,
            );

        if (currentPlaylist == null) {
          return const Scaffold(
            body: Center(child: Text('Playlist not found')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Text(
                  currentPlaylist.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ── Play All / Add to Queue row ─────────────────────
              SliverToBoxAdapter(
                child: _buildActionRow(context, currentPlaylist),
              ),

              // ── Video list or empty/loading states ──────────────
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (currentPlaylist.videoIds.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context))
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final videoTile = _cachedVideos[index];
                        if (videoTile == null) {
                          return const ListTile(
                            title: Text('Video unavailable'),
                          );
                        }
                        final quickVideo = {
                          'id': videoTile.id,
                          'title': videoTile.title,
                        };
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Dismissible(
                            key: Key(videoTile.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                            ),
                            onDismissed: (direction) {
                              context
                                  .read<CustomPlaylistsCubit>()
                                  .removeVideoFromPlaylist(
                                      currentPlaylist.id, videoTile.id);
                              setState(() {
                                _cachedVideos.removeAt(index);
                                _loadedIds.remove(videoTile.id);
                              });
                            },
                            child: VideoMenuDialog(
                              quickVideo: quickVideo,
                              child: VideoTile(
                                video: videoTile,
                                index: index,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _cachedVideos.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionRow(BuildContext context, CustomPlaylist playlist) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, playerState) {
          final isLoading = playerState.status == PlayerStatus.loading;
          final isPlayLoading = isLoading &&
              playerState.loadingOperation == LoadingOperation.play;
          final isQueueLoading = isLoading &&
              playerState.loadingOperation == LoadingOperation.addToQueue;
          final disabled = isLoading || _isLoading;
          final ids = playlist.videoIds.reversed.toList();

          return Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: ids.isNotEmpty && !disabled
                      ? () =>
                          context.read<PlayerCubit>().startPlayingPlaylist(ids)
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
                  onPressed: ids.isNotEmpty && !disabled
                      ? () => context.read<PlayerCubit>().addAllToQueue(ids)
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.video_library_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No videos here yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Long-press a video and choose\n"Save to Playlist..." to add it here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

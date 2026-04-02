import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/custom_playlists/custom_playlists_cubit.dart';
import 'package:my_tube/blocs/custom_playlists/custom_playlists_state.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/models/custom_playlist.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/utils/app_animations.dart';

class CustomPlaylistView extends StatefulWidget {
  final CustomPlaylist initialPlaylist;

  const CustomPlaylistView({super.key, required this.initialPlaylist});

  @override
  State<CustomPlaylistView> createState() => _CustomPlaylistViewState();
}

class _CustomPlaylistViewState extends State<CustomPlaylistView>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<models.VideoTile?> _cachedVideos = [];
  PersistentUiCubit? _uiCubit;
  late AnimationController _staggerController;
  // track the last loaded IDs to avoid unnecessary re-fetches
  List<String> _loadedIds = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _uiCubit ??= context.read<PersistentUiCubit>();
  }

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    _loadMetadata(widget.initialPlaylist);
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
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
    return BlocListener<CustomPlaylistsCubit, CustomPlaylistsState>(
        listener: (context, state) {
      final currentPlaylist =
          state.playlists.cast<CustomPlaylist?>().firstWhere(
                (p) => p?.id == widget.initialPlaylist.id,
                orElse: () => null,
              );
      if (currentPlaylist != null &&
          currentPlaylist.videoIds.join() != _loadedIds.join()) {
        _loadMetadata(currentPlaylist);
      }
    }, child: BlocBuilder<CustomPlaylistsCubit, CustomPlaylistsState>(
      builder: (context, state) {
        final currentPlaylist =
            state.playlists.cast<CustomPlaylist?>().firstWhere(
                  (p) => p?.id == widget.initialPlaylist.id,
                  orElse: () => widget.initialPlaylist,
                );

        if (currentPlaylist == null) {
          return const Scaffold(
            body: Center(child: Text('Playlist not found')),
          );
        }

        // Trigger stagger animation when content loads
        if (!_isLoading && !_staggerController.isAnimating) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _staggerController.reset();
              _staggerController.forward();
            }
          });
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
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') {
                        _showRenameDialog(context, currentPlaylist);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, currentPlaylist);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Rename playlist'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline),
                            SizedBox(width: 8),
                            Text('Delete playlist'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
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
                          child: _buildStaggeredVideoItem(
                            context,
                            videoTile,
                            quickVideo,
                            index,
                            currentPlaylist,
                          ),
                        );
                      },
                      childCount: _cachedVideos.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: 16)),
            ],
          ),
        );
      },
    ));
  }

  Widget _buildStaggeredVideoItem(
    BuildContext context,
    models.VideoTile video,
    Map<String, String> quickVideo,
    int index,
    CustomPlaylist playlist,
  ) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
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
              child: Dismissible(
                key: Key(video.id),
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
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                onDismissed: (direction) {
                  context
                      .read<CustomPlaylistsCubit>()
                      .removeVideoFromPlaylist(playlist.id, video.id);
                  setState(() {
                    _cachedVideos.removeAt(index);
                    _loadedIds.remove(video.id);
                  });
                },
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

  void _showRenameDialog(BuildContext parentContext, CustomPlaylist playlist) {
    final TextEditingController controller =
        TextEditingController(text: playlist.title);
    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Playlist'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'New playlist name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty && text != playlist.title) {
                  parentContext
                      .read<CustomPlaylistsCubit>()
                      .updatePlaylistTitle(playlist.id, text);
                  Navigator.of(context).pop();
                } else if (text == playlist.title) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext parentContext, CustomPlaylist playlist) {
    showDialog(
      context: parentContext,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.delete_outline,
                  color: Theme.of(parentContext).colorScheme.error),
              const SizedBox(width: 8),
              const Text('Delete Playlist'),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text('Are you sure you want to delete "${playlist.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                parentContext
                    .read<CustomPlaylistsCubit>()
                    .deletePlaylist(playlist.id);
                // First close the dialog
                Navigator.of(ctx).pop();
                // Then pop the playlist view itself since it was deleted
                if (mounted) {
                  Navigator.of(parentContext).pop();
                }
              },
              child: Text(
                'Delete',
                style:
                    TextStyle(color: Theme.of(parentContext).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

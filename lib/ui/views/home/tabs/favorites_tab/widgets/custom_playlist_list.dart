import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/custom_playlists/custom_playlists_cubit.dart';
import 'package:my_tube/blocs/custom_playlists/custom_playlists_state.dart';
import 'package:my_tube/models/custom_playlist.dart';
import 'package:my_tube/router/app_navigator.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';

class CustomPlaylistList extends StatelessWidget {
  const CustomPlaylistList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomPlaylistsCubit, CustomPlaylistsState>(
      builder: (context, state) {
        if (state.status == CustomPlaylistsStatus.loading) {
          return const CustomSkeletonGridList();
        }

        if (state.playlists.isEmpty) {
          return const _EmptyMyPlaylistsState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.playlists.length,
          itemBuilder: (context, index) {
            final playlist = state.playlists[index];
            return _PlaylistListItem(playlist: playlist);
          },
        );
      },
    );
  }
}

class _EmptyMyPlaylistsState extends StatelessWidget {
  const _EmptyMyPlaylistsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.playlist_add,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No playlists yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Long-press any video and choose\n"Save to Playlist..." to get started.',
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

class _PlaylistListItem extends StatelessWidget {
  final CustomPlaylist playlist;

  const _PlaylistListItem({required this.playlist});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final videoCount = playlist.videoIds.length;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 56,
          height: 56,
          color: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.playlist_play_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
      ),
      title: Text(
        playlist.title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$videoCount ${videoCount == 1 ? 'video' : 'videos'}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
        onSelected: (value) {
          if (value == 'rename') {
            _showRenameDialog(context, playlist);
          } else if (value == 'delete') {
            _showDeleteDialog(context, playlist);
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
      onTap: () {
        AppNavigator.pushCustomPlaylist(context, playlist);
      },
    );
  }

  void _showDeleteDialog(BuildContext context, CustomPlaylist playlist) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
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
                context
                    .read<CustomPlaylistsCubit>()
                    .deletePlaylist(playlist.id);
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
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
}

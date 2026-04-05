import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/custom_playlists/custom_playlists_cubit.dart';
import 'package:my_tube/blocs/custom_playlists/custom_playlists_state.dart';

class AddToPlaylistDialog extends StatelessWidget {
  final String videoId;

  const AddToPlaylistDialog({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Save to Playlist'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: BlocBuilder<CustomPlaylistsCubit, CustomPlaylistsState>(
          builder: (context, state) {
            if (state.status == CustomPlaylistsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final playlists = state.playlists;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (playlists.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'No playlists yet.\nCreate one below!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (playlists.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          final isInPlaylist =
                              playlist.videoIds.contains(videoId);

                          return CheckboxListTile(
                            title: Text(playlist.title),
                            subtitle: Text(
                              '${playlist.videoIds.length} videos',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            value: isInPlaylist,
                            onChanged: (bool? value) {
                              if (value == true) {
                                context
                                    .read<CustomPlaylistsCubit>()
                                    .addVideoToPlaylist(playlist.id, videoId);
                              } else {
                                context
                                    .read<CustomPlaylistsCubit>()
                                    .removeVideoFromPlaylist(
                                        playlist.id, videoId);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 4),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.add_circle_outline,
                        color: theme.colorScheme.primary),
                    title: Text(
                      'New Playlist',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                    onTap: () => _showCreatePlaylistDialog(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  void _showCreatePlaylistDialog(BuildContext parentContext) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Playlist'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Playlist name',
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
                if (text.isNotEmpty) {
                  parentContext
                      .read<CustomPlaylistsCubit>()
                      .createPlaylist(text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

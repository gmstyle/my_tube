import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/services/download_service.dart';

class VideoMenuDialog extends StatelessWidget {
  const VideoMenuDialog(
      {super.key, required this.quickVideo, required this.child});
  final Map<String, String> quickVideo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final id = quickVideo['id']!;
    final title = quickVideo['title']!;

    return GestureDetector(
      onLongPress: () {
        _showEnhancedVideoMenu(context, id, title);
      },
      child: child,
    );
  }

  void _showEnhancedVideoMenu(
      BuildContext context, String videoId, String videoTitle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Video Options'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Favorite toggle with enhanced animation
              _buildFavoriteOption(context, videoId),
              const Divider(),

              // Queue management
              _buildQueueOption(context, videoId),
              const Divider(),

              // Download options
              _buildDownloadOptions(context, videoId, videoTitle),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFavoriteOption(BuildContext context, String videoId) {
    return BlocBuilder<FavoritesVideoBloc, FavoritesVideoState>(
      builder: (context, state) {
        final favoritesBloc = context.read<FavoritesVideoBloc>();
        final isFavorite =
            favoritesBloc.favoritesRepository.videoIds.contains(videoId);

        return ListTile(
          leading: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFavorite),
              color: isFavorite
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          title:
              Text(isFavorite ? 'Remove from favorites' : 'Add to favorites'),
          onTap: () {
            if (isFavorite) {
              favoritesBloc.add(RemoveFromFavorites(videoId));
            } else {
              favoritesBloc.add(AddToFavorites(videoId));
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildQueueOption(BuildContext context, String videoId) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final playerCubit = context.read<PlayerCubit>();
        final isInQueue = playerCubit.mtPlayerService.queue.value
            .map((e) => e.id)
            .contains(videoId);

        return ListTile(
          leading: Icon(
            isInQueue ? Icons.remove : Icons.playlist_add,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(isInQueue ? 'Remove from queue' : 'Add to queue'),
          onTap: () {
            if (isInQueue) {
              playerCubit.removeFromQueue(videoId);
            } else {
              playerCubit.addToQueue(videoId);
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildDownloadOptions(
      BuildContext context, String videoId, String videoTitle) {
    final downloadService = context.read<DownloadService>();
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.video_library,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Download Video'),
          subtitle: const Text('Full quality with audio'),
          onTap: () {
            downloadService.download(
              videos: [
                {'id': videoId, 'title': videoTitle}
              ],
              context: context,
            );
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: Icon(
            Icons.music_note,
            color: theme.colorScheme.secondary,
          ),
          title: const Text('Download Audio Only'),
          subtitle: const Text('Audio track only'),
          onTap: () {
            downloadService.download(
              videos: [
                {'id': videoId, 'title': videoTitle}
              ],
              context: context,
              isAudioOnly: true,
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

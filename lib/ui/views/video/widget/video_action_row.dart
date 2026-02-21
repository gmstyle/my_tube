import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/services/download_service.dart';

/// A row of icon+label action buttons shown below the playback controls.
/// Includes Download (opens a bottom sheet) and Save/Favorite.
class VideoActionRow extends StatelessWidget {
  const VideoActionRow({super.key, required this.mediaItem});

  final MediaItem? mediaItem;

  void _showDownloadSheet(BuildContext context) {
    if (mediaItem == null) return;
    final downloadService = context.read<DownloadService>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(sheetContext)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.video_file_outlined),
              title: const Text('Download video'),
              onTap: () {
                downloadService.download(
                  videos: [
                    {'id': mediaItem!.id, 'title': mediaItem!.title}
                  ],
                  context: context,
                );
                Navigator.of(sheetContext).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note_outlined),
              title: const Text('Download audio only'),
              onTap: () {
                downloadService.download(
                  videos: [
                    {'id': mediaItem!.id, 'title': mediaItem!.title}
                  ],
                  context: context,
                  isAudioOnly: true,
                );
                Navigator.of(sheetContext).pop();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Download
        _ActionButton(
          icon: Icons.download_outlined,
          label: 'Download',
          onTap: mediaItem == null ? null : () => _showDownloadSheet(context),
        ),

        // Favorite
        BlocBuilder<FavoritesVideoBloc, FavoritesVideoState>(
          builder: (context, state) {
            final bloc = context.read<FavoritesVideoBloc>();
            final isFavorite =
                bloc.favoritesRepository.videoIds.contains(mediaItem?.id);
            return _ActionButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              label: isFavorite ? 'Saved' : 'Save',
              color: isFavorite ? Theme.of(context).colorScheme.error : null,
              onTap: mediaItem == null
                  ? null
                  : () {
                      if (isFavorite) {
                        bloc.add(RemoveFromFavorites(mediaItem!.id));
                      } else {
                        bloc.add(AddToFavorites(mediaItem!.id));
                      }
                    },
            );
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (onTap == null
            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)
            : Theme.of(context).colorScheme.onSurface);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: effectiveColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: effectiveColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

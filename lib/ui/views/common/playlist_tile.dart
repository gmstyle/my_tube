import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/utils/utils.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({super.key, required this.playlist});

  final models.PlaylistTile playlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      leading: SizedBox(
        height: 84,
        width: 120,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Utils.buildImageWithFallback(
                thumbnailUrl: playlist.thumbnailUrl,
                context: context,
                placeholder: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.playlist_play,
                    size: 32,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              // subtle overlay for legibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Theme.of(context)
                          .colorScheme
                          .shadow
                          .withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
              // top-left badge with count
              if (playlist.videoCount != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.queue_play_next,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${playlist.videoCount}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      title: Text(
        playlist.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: playlist.author != null
          ? Text(
              playlist.author!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              overflow: TextOverflow.ellipsis,
            )
          : null,
    );
  }
}

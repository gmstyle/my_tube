import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/utils/utils.dart';

class PlaylistGridItem extends StatelessWidget {
  const PlaylistGridItem({super.key, required this.playlist});

  final ResourceMT playlist;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Stack(
            fit: StackFit.expand,
            children: [
              playlist.thumbnailUrl != null || playlist.base64Thumbnail != null
                  ? Utils.buildImageWithFallback(
                      thumbnailUrl: playlist.thumbnailUrl,
                      base64Thumbnail: playlist.base64Thumbnail,
                      context: context,
                      placeholder: Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.playlist_play,
                          size: 32,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.playlist_play,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: Utils.getOverlayGradient(context),
                ),
              ),
              Positioned(
                top: 8,
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.album_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            playlist.title!,
                            maxLines: 2,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (playlist.channelTitle != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              playlist.channelTitle!,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (playlist.videoCount != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${playlist.videoCount} videos',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              )
            ],
          )),
    );
  }
}

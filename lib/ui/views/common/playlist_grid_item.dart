import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/models/playlist_mt.dart';

class PlaylistGridItem extends StatelessWidget {
  const PlaylistGridItem({super.key, required this.playlist});

  final PlaylistMT playlist;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                  imageUrl: playlist.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const FlutterLogo()),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}

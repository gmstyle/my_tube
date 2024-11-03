import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/utils/utils.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({super.key, required this.playlist});

  final ResourceMT playlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        height: 90,
        width: 90,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                playlist.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: playlist.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          // show base64 image if error
                          return Utils.buildImage(
                              playlist.base64Thumbnail, context);
                        },
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.9),
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Icon(
                    Icons.album_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              ],
            )),
      ),
      title: Text(
        playlist.title ?? '',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (playlist.channelTitle != null)
            Flexible(
              child: Text(
                playlist.channelTitle!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Flexible(
            child: Text(
              playlist.videoCount != null
                  ? '${playlist.videoCount} videos'
                  : '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
    /* return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    playlist.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: playlist.thumbnailUrl!,
                            height: MediaQuery.of(context).size.height * 0.09,
                            width: MediaQuery.of(context).size.width * 0.2,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              // show base64 image if error
                              return Utils.buildImage(
                                  playlist.base64Thumbnail, context);
                            },
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              height: MediaQuery.of(context).size.height * 0.09,
                              width: MediaQuery.of(context).size.width * 0.2,
                            ),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.9),
                          ],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Icon(
                        Icons.album_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  ],
                )),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        playlist.title ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        playlist.channelTitle ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        playlist.videoCount != null
                            ? '${playlist.videoCount} videos'
                            : '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ); */
  }
}

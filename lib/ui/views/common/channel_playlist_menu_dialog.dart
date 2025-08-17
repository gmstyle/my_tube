import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/utils/enums.dart';

class ChannelPlaylistMenuDialog extends StatelessWidget {
  const ChannelPlaylistMenuDialog(
      {super.key, required this.id, required this.kind, required this.child});
  final String id;
  final Kind kind;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final favoritesChannelBloc = context.read<FavoritesChannelBloc>();
    final favoritesPlaylistBloc = context.read<FavoritesPlaylistBloc>();

    return GestureDetector(
      onLongPress: () {
        // show option dialog
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // show the option to remove Channel from the favorites if it is in the favorites
                    if (kind == Kind.channel &&
                        favoritesChannelBloc.favoritesRepository.channelIds
                            .contains(id))
                      ListTile(
                        leading: const Icon(Icons.remove),
                        title: const Text('Remove from favorites'),
                        onTap: () {
                          favoritesChannelBloc
                              .add(RemoveFromFavoritesChannel(id));
                          context.pop();
                        },
                      ),

                    // show the option to add Channel to the favorites if it is not in the favorites
                    if (kind == Kind.channel &&
                        !favoritesChannelBloc.favoritesRepository.channelIds
                            .contains(id))
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: const Text('Add to favorites'),
                        onTap: () {
                          favoritesChannelBloc.add(AddToFavoritesChannel(id));

                          context.pop();
                        },
                      ),

                    // show the option to remove Playlist from the favorites if it is in the favorites
                    if (kind == Kind.playlist &&
                        favoritesPlaylistBloc.favoritesRepository.playlistIds
                            .contains(id))
                      ListTile(
                        leading: const Icon(Icons.remove),
                        title: const Text('Remove from favorites'),
                        onTap: () {
                          favoritesPlaylistBloc
                              .add(RemoveFromFavoritesPlaylist(id));

                          context.pop();
                        },
                      ),

                    // show the option to add Playlist to the favorites if it is not in the favorites
                    if (kind == Kind.playlist &&
                        !favoritesPlaylistBloc.favoritesRepository.playlistIds
                            .contains(id))
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: const Text('Add to favorites'),
                        onTap: () {
                          favoritesPlaylistBloc.add(AddToFavoritesPlaylist(id));

                          context.pop();
                        },
                      ),
                  ],
                ),
              );
            });
      },
      child: child,
    );
  }
}

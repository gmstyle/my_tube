import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/utils/enums.dart';

class ChannelPlaylistMenuDialog extends StatelessWidget {
  const ChannelPlaylistMenuDialog({
    super.key,
    required this.id,
    required this.kind,
    required this.child,
    this.title,
  });

  final String id;
  final Kind kind;
  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showEnhancedMenu(context);
      },
      child: child,
    );
  }

  void _showEnhancedMenu(BuildContext context) {
    final String dialogTitle =
        kind == Kind.channel ? 'Channel Options' : 'Playlist Options';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(dialogTitle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Favorite toggle with enhanced animation
              _buildFavoriteOption(context),
              const Divider(),

              // Navigation option
              _buildNavigationOption(context),

              // Additional options based on type
              if (kind == Kind.playlist) ...[
                const Divider(),
                _buildPlaylistSpecificOptions(context),
              ],

              if (kind == Kind.channel) ...[
                const Divider(),
                _buildChannelSpecificOptions(context),
              ],
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

  Widget _buildFavoriteOption(BuildContext context) {
    if (kind == Kind.channel) {
      return BlocBuilder<FavoritesChannelBloc, FavoritesChannelState>(
        builder: (context, state) {
          final favoritesBloc = context.read<FavoritesChannelBloc>();
          final isFavorite =
              favoritesBloc.favoritesRepository.channelIds.contains(id);

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
            title: Text(
              isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
            subtitle: Text(
              isFavorite
                  ? 'Remove this channel from your favorites'
                  : 'Save this channel to your favorites',
            ),
            onTap: () {
              if (isFavorite) {
                favoritesBloc.add(RemoveFromFavoritesChannel(id));
              } else {
                favoritesBloc.add(AddToFavoritesChannel(id));
              }
              Navigator.of(context).pop();
            },
          );
        },
      );
    } else {
      return BlocBuilder<FavoritesPlaylistBloc, FavoritesPlaylistState>(
        builder: (context, state) {
          final favoritesBloc = context.read<FavoritesPlaylistBloc>();
          final isFavorite =
              favoritesBloc.favoritesRepository.playlistIds.contains(id);

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
            title: Text(
              isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
            subtitle: Text(
              isFavorite
                  ? 'Remove this playlist from your favorites'
                  : 'Save this playlist to your favorites',
            ),
            onTap: () {
              if (isFavorite) {
                favoritesBloc.add(RemoveFromFavoritesPlaylist(id));
              } else {
                favoritesBloc.add(AddToFavoritesPlaylist(id));
              }
              Navigator.of(context).pop();
            },
          );
        },
      );
    }
  }

  Widget _buildNavigationOption(BuildContext context) {
    final theme = Theme.of(context);

    if (kind == Kind.channel) {
      return ListTile(
        leading: Icon(
          Icons.person,
          color: theme.colorScheme.primary,
        ),
        title: const Text('View Channel'),
        subtitle: const Text('Open channel page'),
        onTap: () {
          context.goNamed(AppRoute.channel.name, extra: {'channelId': id});
        },
      );
    } else {
      return ListTile(
        leading: Icon(
          Icons.playlist_play,
          color: theme.colorScheme.primary,
        ),
        title: const Text('View Playlist'),
        subtitle: const Text('Open playlist page'),
        onTap: () {
          context.goNamed(AppRoute.playlist.name, extra: {'playlistId': id});
        },
      );
    }
  }

  Widget _buildChannelSpecificOptions(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.share,
            color: theme.colorScheme.secondary,
          ),
          title: const Text('Share Channel'),
          subtitle: const Text('Share this channel with others'),
          onTap: () {
            Navigator.of(context).pop();
            // TODO: Implement channel sharing
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sharing channel: ${title ?? id}'),
                backgroundColor: theme.colorScheme.secondary,
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.notifications_outlined,
            color: theme.colorScheme.tertiary,
          ),
          title: const Text('Subscribe'),
          subtitle: const Text('Get notified of new videos'),
          onTap: () {
            Navigator.of(context).pop();
            // TODO: Implement subscription
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Subscribed to: ${title ?? id}'),
                backgroundColor: theme.colorScheme.tertiary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlaylistSpecificOptions(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.download,
            color: theme.colorScheme.secondary,
          ),
          title: const Text('Download Playlist'),
          subtitle: const Text('Download all videos in playlist'),
          onTap: () {
            Navigator.of(context).pop();
            // TODO: Implement playlist download
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloading playlist: ${title ?? id}'),
                backgroundColor: theme.colorScheme.secondary,
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.share,
            color: theme.colorScheme.tertiary,
          ),
          title: const Text('Share Playlist'),
          subtitle: const Text('Share this playlist with others'),
          onTap: () {
            Navigator.of(context).pop();
            // TODO: Implement playlist sharing
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sharing playlist: ${title ?? id}'),
                backgroundColor: theme.colorScheme.tertiary,
              ),
            );
          },
        ),
      ],
    );
  }
}

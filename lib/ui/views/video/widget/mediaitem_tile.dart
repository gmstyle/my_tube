import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/common/shared_content_tile.dart';

class MediaitemTile extends StatefulWidget {
  const MediaitemTile(
      {super.key, required this.mediaItem, this.darkBackground = false});

  final MediaItem mediaItem;
  final bool darkBackground;

  @override
  State<MediaitemTile> createState() => _MediaitemTileState();
}

class _MediaitemTileState extends State<MediaitemTile>
    with SingleTickerProviderStateMixin {
  // This widget is now a thin wrapper; animations are handled by SharedContentTile.

  @override
  Widget build(BuildContext context) {
    final data = TileData.fromMediaItem(widget.mediaItem);
    final child = SharedContentTile(
        data: data, showActions: false, enableScrollAnimation: false);

    final playerCubit = BlocProvider.of<PlayerCubit>(context);

    return Dismissible(
      key: Key(widget.mediaItem.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        playerCubit.removeFromQueue(widget.mediaItem.id).then((value) {
          if (value == false && context.mounted) {
            context.pop();
          }
        });
      },
      background: const DismissibleBackgroud(),
      child: child,
    );
  }
}

class DismissibleBackgroud extends StatelessWidget {
  const DismissibleBackgroud({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.error,
      child: Row(
        children: [
          Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.onError,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            'Remove from queue',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          )
        ],
      ),
    );
  }
}

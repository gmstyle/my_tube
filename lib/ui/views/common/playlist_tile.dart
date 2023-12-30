import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_bloc.dart';
import 'package:my_tube/models/resource_mt.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({super.key, required this.playlist});

  final ResourceMT playlist;

  @override
  Widget build(BuildContext context) {
    final queueCubit = context.read<FavoritesBloc>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
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
                      ? Image.network(
                          playlist.thumbnailUrl!,
                          height: MediaQuery.of(context).size.height * 0.09,
                          width: MediaQuery.of(context).size.width * 0.2,
                          fit: BoxFit.cover,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const SizedBox(
                            child: FlutterLogo(),
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
                  const Positioned(
                    top: 4,
                    left: 4,
                    child: Icon(
                      Icons.album_rounded,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
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
                Text(
                  playlist.title ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                ),
                Text(playlist.channelTitle ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
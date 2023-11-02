import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/models/playlist_mt.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/resource_tile.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    final playlistState = context.watch<PlaylistBloc>().state;
    return BlocBuilder<PlaylistBloc, PlaylistState>(
      builder: ((context, state) {
        switch (state.status) {
          case PlaylistStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case PlaylistStatus.loaded:
            final playlist = state.response?.playlist;
            return Column(
              children: [
                Header(playlist: playlist),
                Expanded(
                  child: ListView.builder(
                      itemCount: playlist?.videos!.length,
                      itemBuilder: (context, index) {
                        final video = state.response?.playlist!.videos![index];
                        return GestureDetector(
                          onTap: () async {
                            await context
                                .read<MiniPlayerCubit>()
                                .startPlaying(video.id!);
                          },
                          child: ResourceTile(resource: video!),
                        );
                      }),
                ),
              ],
            );

          case PlaylistStatus.failure:
            return Center(
              child: Text(state.error!),
            );

          default:
            return const Center(child: CircularProgressIndicator());
        }
      }),
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.playlist,
  });

  final PlaylistMT? playlist;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(playlist?.thumbnailUrl ?? '',
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.3,
              fit: BoxFit.cover),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: Text(
                playlist?.title ?? '',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

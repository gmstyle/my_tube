import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/ui/views/common/resource_tile.dart';
import 'package:my_tube/ui/views/playlist/widgets/playlist_header.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistBloc, PlaylistState>(
      builder: ((context, state) {
        switch (state.status) {
          case PlaylistStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case PlaylistStatus.loaded:
            final playlist = state.response;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    PlaylistHeader(playlist: playlist),
                    const SizedBox(height: 16),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: playlist?.videos!.length,
                        itemBuilder: (context, index) {
                          final video = playlist?.videos![index];
                          return GestureDetector(
                            onTap: () async {
                              await context
                                  .read<MiniPlayerCubit>()
                                  .startPlaying(video.id!);
                            },
                            child: ResourceTile(resource: video!),
                          );
                        }),
                  ],
                ),
              ),
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

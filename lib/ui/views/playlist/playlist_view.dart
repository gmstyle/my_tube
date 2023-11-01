import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/resource_tile.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView(
      {super.key, required this.playlistTitle, required this.playlistId});

  final String playlistTitle;
  final String playlistId;

  @override
  Widget build(BuildContext context) {
    final playlistState = context.watch<PlaylistBloc>().state;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppbar(
          title: playlistTitle,
        ),
        body: BlocBuilder<PlaylistBloc, PlaylistState>(
          builder: ((context, state) {
            switch (state.status) {
              case PlaylistStatus.loading:
                return const Center(child: CircularProgressIndicator());

              case PlaylistStatus.loaded:
                return ListView.builder(
                    itemCount: state.response?.resources.length,
                    itemBuilder: (context, index) {
                      final video = state.response?.resources[index];
                      return GestureDetector(
                        onTap: () async {
                          await context
                              .read<MiniPlayerCubit>()
                              .startPlaying(video.id!);
                        },
                        child: ResourceTile(resource: video!),
                      );
                    });

              case PlaylistStatus.failure:
                return Center(
                  child: Text(state.error!),
                );

              default:
                return const Center(child: CircularProgressIndicator());
            }
          }),
        ),
        /* floatingActionButton: playlistState.status == PlaylistStatus.loaded
            ? FloatingActionButton(
                onPressed: () {
                  context
                      .read<MiniPlayerCubit>()
                      .startPlayingPlaylist(playlistState.videoIds!);
                },
                child: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).primaryColor,
                ),
              )
            : null, */
      ),
    );
  }
}

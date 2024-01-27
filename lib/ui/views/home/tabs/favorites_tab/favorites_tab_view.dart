import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_bloc.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/favorites_header.dart';

class QueueTabView extends StatelessWidget {
  const QueueTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final miniplayerCubit = context.read<PlayerCubit>();

    context.read<FavoritesBloc>().add(GetFavorites());

    return BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
      switch (state.status) {
        case FavoritesStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case FavoritesStatus.success:
          final favorites = state.favorites!.reversed.toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FavoritesHeader(favorites: favorites),
              ),
              Expanded(
                child: favorites.isNotEmpty
                    ? ListView.builder(
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final video = favorites[index];
                          return PlayPauseGestureDetector(
                              resource: video,
                              child: VideoMenuDialog(
                                  video: video,
                                  child: VideoTile(video: video)));
                        },
                      )
                    : const Center(child: Text('No favorites yet')),
              ),
            ],
          );
        case FavoritesStatus.failure:
          return Center(child: Text(state.error!));
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/channel_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/playlist_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/video_favorites.dart';

class FavoritesTabView extends StatelessWidget {
  const FavoritesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesBloc = context.read<FavoritesBloc>();
    final playerCubit = context.read<PlayerCubit>();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Theme.of(context).colorScheme.onPrimary,
              tabs: [
                // favorites videos
                Tab(
                  icon: Icon(
                    Icons.video_library,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                // favorites channels
                Tab(
                  icon: Icon(MdiIcons.accountGroupOutline,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
                // favorites playlists
                Tab(
                  icon: Icon(Icons.album,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ]),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                VideoFavorites(
                    favoritesBloc: favoritesBloc, playerCubit: playerCubit),
                ChannelFavorites(
                  favoritesBloc: favoritesBloc,
                ),
                PlaylistFavorites(
                  favoritesBloc: favoritesBloc,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

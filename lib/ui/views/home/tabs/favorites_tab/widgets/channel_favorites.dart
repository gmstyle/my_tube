import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/channel_tile.dart';
import 'package:my_tube/ui/views/common/channel_playlist_menu_dialog.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/empty_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/favorites_header.dart';
import 'package:my_tube/utils/enums.dart';

class ChannelFavorites extends StatelessWidget {
  const ChannelFavorites({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesChannelBloc, FavoritesChannelState>(
        builder: (context, state) {
      switch (state.status) {
        case FavoritesChannelStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case FavoritesChannelStatus.success:
          final favorites = state.channels!
              .where((channel) => channel.title
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
              .toList()
              .reversed
              .toList();

          final ids = favorites.map((channel) => channel.id).toList();

          return Column(
            children: [
              FavoritesHeader(
                title: 'Channels',
                ids: ids,
              ),
              Expanded(
                child: favorites.isNotEmpty
                    ? ListView.builder(
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final channel = favorites[index];
                          return GestureDetector(
                            onTap: () {
                              context.goNamed(AppRoute.channelFavorites.name,
                                  extra: {'channelId': channel.id});
                            },
                            child: ChannelPlaylistMenuDialog(
                                id: channel.id,
                                kind: Kind.channel,
                                child: ChannelTile(channel: channel)),
                          );
                        },
                      )
                    : const EmptyFavorites(
                        message: 'No favorite channels yet',
                      ),
              ),
            ],
          );
        case FavoritesChannelStatus.failure:
          return Center(child: Text(state.error!));
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

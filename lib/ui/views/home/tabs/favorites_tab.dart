import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_tab_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class FavoritesTab extends StatelessWidget {
  FavoritesTab({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final favoritesTabBloc = context.read<FavoritesTabBloc>();
    return BlocBuilder<FavoritesTabBloc, FavoritesTabState>(
        builder: (context, state) {
      switch (state.status) {
        case FavoritesStatus.loading:
          return const Center(child: CircularProgressIndicator());

        case FavoritesStatus.success:
          return RefreshIndicator(
            onRefresh: () async {
              favoritesTabBloc.add(const GetFavorites());
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (state.response?.nextPageToken != null) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    favoritesTabBloc.add(GetNextPageFavorites(
                        nextPageToken: state.response!.nextPageToken!));
                  }
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.response!.videos.length,
                itemBuilder: (context, index) {
                  if (index >= state.response!.videos.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    final video = state.response?.videos[index];
                    return GestureDetector(
                        onTap: () async {
                          await context
                              .read<MiniPlayerCubit>()
                              .showMiniPlayer(video);
                        },
                        child: VideoTile(video: video!));
                  }
                },
              ),
            ),
          );
        case FavoritesStatus.error:
          return Center(
            child: Text(state.error!),
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

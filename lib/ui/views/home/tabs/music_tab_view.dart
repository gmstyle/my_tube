import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/music_tab/music_tab_bloc.dart';

class MusicTabView extends StatelessWidget {
  MusicTabView({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final favoritesTabBloc = context.read<MusicTabBloc>();
    return BlocBuilder<MusicTabBloc, MusicTabState>(builder: (context, state) {
      switch (state.status) {
        case FavoritesStatus.loading:
          return const Center(child: CircularProgressIndicator());

        case FavoritesStatus.success:
          return RefreshIndicator(
              onRefresh: () async {
                favoritesTabBloc.add(const GetMusicHome());
              },
              child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    /* if (state.response?.nextPageToken != null) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    favoritesTabBloc.add(GetNextPageFavorites(
                        nextPageToken: state.response!.nextPageToken!));
                  }
                }*/
                    return false;
                  },
                  child: /* ListView.builder(
                controller: _scrollController,
                itemCount: state.response!.resources.length,
                itemBuilder: (context, index) {
                  if (index >= state.response!.resources.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    final video = state.response?.resources[index];
                    return GestureDetector(
                        onTap: () async {
                          await context
                              .read<MiniPlayerCubit>()
                              .startPlaying(video);
                        },
                        child: ResourceTile(resource: video!));
                  }
                },
              ), */
                      Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: const Text('Slider'),
                      )
                    ],
                  )));
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

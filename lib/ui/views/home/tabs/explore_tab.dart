import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/ui/views/common/mini_player.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class ExploreTab extends StatelessWidget {
  ExploreTab({super.key});

  final ScrollController _scrollController = ScrollController();

  bool isPlayerVisible = false;
  @override
  Widget build(BuildContext context) {
    final exploreTabBloc = context.read<ExploreTabBloc>();
    final miniPlayerHeight = MediaQuery.of(context).size.height * 0.1;

    return BlocBuilder<ExploreTabBloc, ExploreTabState>(
      builder: (context, state) {
        switch (state.status) {
          case YoutubeStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case YoutubeStatus.loaded:
            return RefreshIndicator(
              onRefresh: () async {
                exploreTabBloc.add(const GetVideos());
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    /// Sono arrivato alla fine della lista quindi carico altri video
                    /// finchè non arrivo al massimo di 100 video
                    if (state.videos!.length < 100) {
                      exploreTabBloc.add(GetNextPageVideos(
                          nextPageToken: state.nextPageToken));
                    }
                  }
                  return false;
                },
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: state.videos!.length,
                        itemBuilder: (context, index) {
                          if (index >= state.videos!.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            final video = state.videos?[index];
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

                    /// Mini player
                    BlocBuilder<MiniPlayerCubit, MiniPlayerState>(
                        builder: (context, state) {
                      switch (state.status) {
                        case MiniPlayerStatus.shown:
                          return AnimatedContainer(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10))),
                            duration: const Duration(milliseconds: 500),
                            height: miniPlayerHeight,
                            child: MiniPlayer(
                                video: state.video!,
                                streamUrl: state.streamUrl!),
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),
            );
          case YoutubeStatus.error:
            return Center(
              child: Text(state.error!),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

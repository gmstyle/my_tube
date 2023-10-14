import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class ExploreTab extends StatelessWidget {
  ExploreTab({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final exploreTabBloc = context.read<ExploreTabBloc>();

    return BlocBuilder<ExploreTabBloc, ExploreTabState>(
      builder: (context, state) {
        switch (state.status) {
          case YoutubeStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case YoutubeStatus.loaded:
            return RefreshIndicator(
              onRefresh: () async {
                exploreTabBloc.add(const GetTrendingVideos());
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (state.response?.nextPageToken != null) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      exploreTabBloc.add(GetNextPageTrendingVideos(
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

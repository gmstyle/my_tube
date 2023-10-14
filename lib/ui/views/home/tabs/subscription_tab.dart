import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/home/subscription_tab/subscription_bloc.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class SubscriptionTab extends StatelessWidget {
  SubscriptionTab({super.key});

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final subscriptionBloc = context.read<SubscriptionBloc>();
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
      switch (state.status) {
        case SubscriptionStatus.loading:
          return const Center(child: CircularProgressIndicator());

        case SubscriptionStatus.loaded:
          return RefreshIndicator(
            onRefresh: () async {
              subscriptionBloc.add(const GetSubscriptions());
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (state.response?.nextPageToken != null) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    subscriptionBloc.add(GetNextPageSubscriptions(
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
                    final video = state.response!.videos[index];
                    return GestureDetector(
                        onTap: () async {
                          await context
                              .read<MiniPlayerCubit>()
                              .showMiniPlayer(video);
                        },
                        child: VideoTile(video: video));
                  }
                },
              ),
            ),
          );

        case SubscriptionStatus.error:
          return Center(
            child: Text(state.error!),
          );

        default:
          return const SizedBox.shrink();
      }
    });
  }
}

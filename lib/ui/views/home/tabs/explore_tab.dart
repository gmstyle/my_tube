import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/home_bloc.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        switch (state.status) {
          case YoutubeStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case YoutubeStatus.loaded:
            return ListView.builder(
              itemCount: state.videos!.length,
              itemBuilder: (context, index) {
                final video = state.videos?[index];
                return VideoTile(video: video!);
              },
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';

class VideoSection extends StatelessWidget {
  const VideoSection(
      {super.key, required this.videos, this.crossAxisCount = 2});
  final List<ResourceMT> videos;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: videos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 8,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 8),
          itemBuilder: (context, index) {
            final video = videos[index];
            return GestureDetector(
              child: VideoGridItem(video: video),
              onTap: () {
                context.read<MiniPlayerCubit>().startPlaying(video);
              },
            );
          }),
    );
  }
}

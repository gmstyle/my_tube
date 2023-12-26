import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class VideoSection extends StatelessWidget {
  const VideoSection(
      {super.key, required this.videos, this.crossAxisCount = 1});
  final List<ResourceMT> videos;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: videos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 8,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 8,
              mainAxisExtent: crossAxisCount > 1
                  ? MediaQuery.of(context).size.width - 64
                  : null),
          itemBuilder: (context, index) {
            final video = videos[index];
            return GestureDetector(
              onTap: () {
                context.read<MiniPlayerCubit>().startPlaying(video.id!);
              },
              child: crossAxisCount > 1
                  ? VideoTile(video: video)
                  : VideoGridItem(video: video),
            );
          }),
    );
  }
}

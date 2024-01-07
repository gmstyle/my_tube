import 'package:flutter/material.dart';
import 'package:my_tube/ui/skeletons/skeleton_video_tile.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Skeleton(
            shimmerGradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            isLoading: true,
            skeleton: const SkeletonVideoTile(),
            child: const SizedBox(),
          ),
        );
      },
    );
  }
}

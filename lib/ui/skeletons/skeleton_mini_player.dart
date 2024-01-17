import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonMiniPlayer extends StatelessWidget {
  const SkeletonMiniPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Skeleton(
          shimmerGradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primary,
            Colors.grey[400]!,
          ], begin: Alignment.centerLeft, end: Alignment.centerRight),
          isLoading: true,
          skeleton: SkeletonItem(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 80,
                    width: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 8,
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                    shape: BoxShape.circle,
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ),
          ),
          child: const SizedBox(),
        ),
      ),
    );
  }
}

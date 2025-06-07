import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Skeletonizer(
            enabled: true,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const Bone.square(
                    size: 80,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Bone.multiText(lines: 3)],
                  ),
                ),
                const SizedBox(width: 8),
                const Bone.iconButton(
                  size: 40,
                )
              ],
            ),
          ),
        ));
  }
}

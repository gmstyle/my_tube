import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonVideoTile extends StatelessWidget {
  const SkeletonVideoTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      shimmerGradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.tertiary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isLoading: true,
      skeleton: SkeletonItem(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.09,
                width: MediaQuery.of(context).size.width * 0.2,
                color: Theme.of(context).colorScheme.primaryContainer,
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    height: 8,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      child: const SizedBox(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonPlaylist extends StatelessWidget {
  const SkeletonPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                itemCount: 6,
                itemBuilder: ((context, index) => Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 80,
                            width: 80,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                height: 8,
                                width: double.infinity,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )))
          ],
        ),
      ),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonMusicHhome extends StatelessWidget {
  const SkeletonMusicHhome({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
        isLoading: true,
        shimmerGradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        skeleton: SkeletonItem(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 16,
                          width: 100,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.20,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.20,
                              width: MediaQuery.of(context).size.width * 0.4,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 16,
                          width: 100,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.25,
                              width: MediaQuery.of(context).size.width * 0.4,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        )),
        child: const SizedBox());
  }
}

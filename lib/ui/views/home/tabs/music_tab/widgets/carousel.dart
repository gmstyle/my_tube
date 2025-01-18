import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';

class Carousel extends StatelessWidget {
  const Carousel({super.key, required this.carouselVideos});

  final List<ResourceMT> carouselVideos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.orientationOf(context) == Orientation.landscape
          ? MediaQuery.of(context).size.height * 0.5
          : MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width,
      child: CarouselView(
          itemExtent: MediaQuery.of(context).size.width * 0.8,
          onTap: (index) async {
            if (carouselVideos[index].id != null) {
              await context
                  .read<PlayerCubit>()
                  .startPlaying(carouselVideos[index].id!);
            }
          },
          children: List.generate(carouselVideos.length, (index) {
            final video = carouselVideos[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  video.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: video.thumbnailUrl!,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                    ),
                  ),
                  Positioned(
                      top: 64,
                      left: 16,
                      right: 8,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  video.channelTitle ?? '',
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  video.title ?? '',
                                  maxLines: 2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ))
                ],
              ),
            );
          })),
    );
  }
}

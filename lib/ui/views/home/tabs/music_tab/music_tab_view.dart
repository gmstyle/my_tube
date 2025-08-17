/* import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/music_tab/music_tab_bloc.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/carousel.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/playlist_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/video_section.dart';

class MusicTabView extends StatelessWidget {
  const MusicTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesTabBloc = context.read<MusicTabBloc>();
    return BlocBuilder<MusicTabBloc, MusicTabState>(builder: (context, state) {
      switch (state.status) {
        case FavoritesStatus.loading:
          return const CustomSkeletonMusicHome();
        case FavoritesStatus.success:
          return RefreshIndicator(
              onRefresh: () async {
                favoritesTabBloc.add(const GetMusicHome());
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Carousel(carouselVideos: state.response!.carouselVideos!),
                    const SizedBox(height: 16),

                    // Sections
                    for (final section in state.response!.sections)
                      Column(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Text(
                                    section.title ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (section.videos != null &&
                                  section.videos!.isNotEmpty)
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: VideoSection(
                                      videos: section.videos!,
                                    ),
                                  ),
                                ),
                              if (section.playlists != null &&
                                  section.playlists!.isNotEmpty)
                                PlaylistSection(playlists: section.playlists!),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ));
        case FavoritesStatus.error:
          return Center(
            child: Text(state.error!),
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }
}
 */

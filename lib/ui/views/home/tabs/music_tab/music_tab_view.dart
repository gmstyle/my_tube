import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/music_tab/music_tab_bloc.dart';
import 'package:my_tube/ui/skeletons/skeleton_music_home.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/carousel.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/playlist_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/video_section.dart';

class MusicTabView extends StatelessWidget {
  MusicTabView({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final favoritesTabBloc = context.read<MusicTabBloc>();
    return BlocBuilder<MusicTabBloc, MusicTabState>(builder: (context, state) {
      switch (state.status) {
        case FavoritesStatus.loading:
          return const SkeletonMusicHhome();
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
                    // TODO: Related videos
                    // Sections
                    for (final section in state.response!.sections)
                      Column(
                        children: [
                          if (section.title != null) const SizedBox(height: 8),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
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
                                            color: Colors.white,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (section.videos != null &&
                                    section.videos!.isNotEmpty)
                                  VideoSection(
                                    videos: section.videos!,
                                  ),
                                if (section.playlists != null &&
                                    section.playlists!.isNotEmpty)
                                  PlaylistSection(
                                      playlists: section.playlists!),
                              ],
                            ),
                          ),
                        ],
                      )
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

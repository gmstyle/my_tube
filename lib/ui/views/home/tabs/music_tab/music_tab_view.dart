import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/music_tab/music_tab_bloc.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

class MusicTabView extends StatefulWidget {
  const MusicTabView({super.key});

  @override
  State<MusicTabView> createState() => _MusicTabViewState();
}

class _MusicTabViewState extends State<MusicTabView> {
  @override
  void initState() {
    super.initState();
    context.read<MusicTabBloc>().add(const GetMusicTabContent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicTabBloc, MusicTabState>(
      builder: (context, state) {
        if (state.status == MusicTabStatus.loading) {
          return const CustomSkeletonMusicHome();
        }

        if (state.status == MusicTabStatus.error) {
          return Center(child: Text('Error: ${state.error}'));
        }

        if (state.status == MusicTabStatus.success) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<MusicTabBloc>().add(const GetMusicTabContent());
            },
            child: CustomScrollView(
              slivers: [
                // 1. New Releases Section
                if (state.newReleases.isNotEmpty)
                  _buildSectionHeader(context, "New Releases"),
                if (state.newReleases.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180, // Approximate height for video tile
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.newReleases.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return SizedBox(
                              width: 250,
                              child: VideoMenuDialog(
                                  quickVideo: {
                                    'id': state.newReleases[index].id,
                                    'title': state.newReleases[index].title,
                                  },
                                  child: VideoGridItem(
                                      video: state.newReleases[index])));
                        },
                      ),
                    ),
                  ),

                // 2. Discover Section (Related to a Favorite)
                if (state.discoverVideo != null &&
                    state.discoverRelated.isNotEmpty) ...[
                  _buildSectionHeader(context,
                      "Because you liked ${state.discoverVideo!.title}"),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.discoverRelated.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return SizedBox(
                              width: 250,
                              child: VideoMenuDialog(
                                  quickVideo: {
                                    'id': state.discoverRelated[index].id,
                                    'title': state.discoverRelated[index].title,
                                  },
                                  child: VideoGridItem(
                                      video: state.discoverRelated[index])));
                        },
                      ),
                    ),
                  ),
                ],

                // 4. Trending Section (Fallback or Extras)
                if (state.trending.isNotEmpty)
                  _buildSectionHeader(
                      context,
                      state.isInternationalTrending
                          ? "International Top Hits"
                          : "Trending Music"),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: VideoMenuDialog(quickVideo: {
                          'id': state.trending[index].id,
                          'title': state.trending[index].title,
                        }, child: VideoTile(video: state.trending[index])),
                      );
                    },
                    childCount: state.trending.length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

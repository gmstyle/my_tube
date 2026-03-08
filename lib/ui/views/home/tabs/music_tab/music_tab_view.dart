import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/music_tab/music_tab_bloc.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_empty_state.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_featured_channels_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_genre_chips_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_horizontal_video_list.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_see_all_sheet.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_section_header.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_trending_section.dart';
import 'package:my_tube/utils/constants.dart';

class MusicTabView extends StatefulWidget {
  const MusicTabView({super.key});

  @override
  State<MusicTabView> createState() => _MusicTabViewState();
}

class _MusicTabViewState extends State<MusicTabView> {
  // NOTE: dispatch is already sent by MusicTabPage; initState is intentionally
  // left without an additional add() to avoid a double fetch.

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicTabBloc, MusicTabState>(
      builder: (context, state) {
        // ── Loading ──────────────────────────────────────────────────────
        if (state.status == MusicTabStatus.loading) {
          return const CustomSkeletonMusicHome();
        }

        // ── Error ────────────────────────────────────────────────────────
        if (state.status == MusicTabStatus.error) {
          return EnhancedErrorState(
            icon: Icons.music_off_outlined,
            title: musicLoadErrorTitle,
            message: state.error ?? musicLoadErrorMessage,
            showBackButton: false,
            onRetry: () =>
                context.read<MusicTabBloc>().add(const GetMusicTabContent()),
          );
        }

        // ── Success ──────────────────────────────────────────────────────
        if (state.status == MusicTabStatus.success) {
          // Include loading flags so the empty-state widget doesn't flicker
          // in while network sections are still fetching.
          final hasPersonalized = state.recentlyPlayed.isNotEmpty ||
              state.newReleases.isNotEmpty ||
              state.discoverRelated.isNotEmpty ||
              state.trending.isNotEmpty ||
              state.isNewReleasesLoading ||
              state.isDiscoverLoading ||
              state.isTrendingLoading;

          // Deduplicate Discover vs New Releases at render time (both
          // sections load in parallel so BLoC can't do it upfront).
          final newReleasesIds = state.newReleases.map((v) => v.id).toSet();
          final dedupedDiscover = state.discoverRelated
              .where((v) => !newReleasesIds.contains(v.id))
              .toList();
          final discoverTitle = state.discoverVideo == null
              ? null
              : musicBecauseYouLikedTitle(state.discoverVideo!.title);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: false,
                automaticallyImplyLeading: false,
                toolbarHeight: 48,
                forceElevated: innerBoxIsScrolled,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Text(
                    musicTabAppBarTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
              ),
            ],
            body: RefreshIndicator(
              onRefresh: () async =>
                  context.read<MusicTabBloc>().add(const GetMusicTabContent()),
              child: CustomScrollView(
                slivers: [
                  // ── 0a. Featured Channels ──────────────────────────
                  if (state.isFeaturedChannelsLoading) ...[
                    const SkeletonSectionHeader(),
                    const SkeletonChannelRow(),
                  ] else if (state.featuredChannels.isNotEmpty) ...[
                    const MusicSectionHeader(
                        title: musicSectionFeaturedChannels),
                    MusicFeaturedChannelsSection(
                        channels: state.featuredChannels),
                  ],

                  // ── 0b. Explore by Genre ───────────────────────────
                  const MusicSectionHeader(title: musicSectionExploreByGenre),
                  const MusicGenreChipsSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 4)),

                  // ── 0c. Continue Listening ─────────────────────────
                  if (state.recentlyPlayed.isNotEmpty) ...[
                    MusicSectionHeader(
                      title: musicSectionContinueListening,
                      onSeeAll: state.recentlyPlayed.length > 5
                          ? () => showMusicSeeAllSheet(
                                context,
                                title: musicSectionContinueListening,
                                videos: state.recentlyPlayed,
                              )
                          : null,
                    ),
                    MusicHorizontalVideoList(videos: state.recentlyPlayed),
                  ],

                  // ── 1. New Releases ────────────────────────────────
                  if (state.isNewReleasesLoading) ...[
                    const SkeletonSectionHeader(),
                    const SkeletonHorizontalCards(),
                  ] else if (state.newReleases.isNotEmpty) ...[
                    MusicSectionHeader(
                      title: musicSectionNewReleases,
                      onSeeAll: state.newReleases.length > 5
                          ? () => showMusicSeeAllSheet(
                                context,
                                title: musicSectionNewReleases,
                                videos: state.newReleases,
                              )
                          : null,
                    ),
                    MusicHorizontalVideoList(videos: state.newReleases),
                  ],

                  // ── 2. Discover ────────────────────────────────────
                  if (state.isDiscoverLoading) ...[
                    const SkeletonSectionHeader(),
                    const SkeletonHorizontalCards(),
                  ] else if (state.discoverVideo != null &&
                      dedupedDiscover.isNotEmpty) ...[
                    MusicSectionHeader(
                      title: discoverTitle!,
                      onSeeAll: dedupedDiscover.length > 5
                          ? () => showMusicSeeAllSheet(
                                context,
                                title: discoverTitle,
                                videos: dedupedDiscover,
                              )
                          : null,
                    ),
                    MusicHorizontalVideoList(videos: dedupedDiscover),
                  ],

                  // ── 3. Trending ────────────────────────────────────
                  if (state.isTrendingLoading) ...[
                    const SkeletonSectionHeader(),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: SkeletonTrendingHero(),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => const SkeletonRankedTile(),
                        childCount: 4,
                      ),
                    ),
                  ] else if (state.trending.isNotEmpty) ...[
                    MusicSectionHeader(
                      title: state.isInternationalTrending
                          ? musicSectionInternationalTopHits
                          : musicSectionTrendingMusic,
                      onSeeAll: state.trending.length > 5
                          ? () => showMusicSeeAllSheet(
                                context,
                                title: state.isInternationalTrending
                                    ? musicSectionInternationalTopHits
                                    : musicSectionTrendingMusic,
                                videos: state.trending,
                                ranked: true,
                              )
                          : null,
                    ),
                    // Hero card for rank #1
                    SliverToBoxAdapter(
                      child: MusicTrendingHeroCard(video: state.trending.first),
                    ),
                    // Ranked list for #2–#5 (inline preview, max 4)
                    if (state.trending.length > 1)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final video = state.trending[index + 1];
                            return MusicRankedTile(
                                rank: index + 2, video: video);
                          },
                          childCount: (state.trending.length - 1).clamp(0, 4),
                        ),
                      ),
                  ],

                  // ── Empty hint (no personalized content yet) ───────
                  if (!hasPersonalized)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: MusicEmptyState(),
                    ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

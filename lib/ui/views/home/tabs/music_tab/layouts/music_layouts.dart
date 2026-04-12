import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/music_tab/music_tab_bloc.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_empty_state.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_featured_channels_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_featured_playlists_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_genre_chips_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_mood_chips_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_horizontal_video_list.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_see_all_sheet.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_section_header.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_trending_section.dart';
import 'package:my_tube/utils/constants.dart';

/// Phone layout for the music tab success state.
class MusicMobileLayout extends StatelessWidget {
  const MusicMobileLayout({super.key, required this.state});

  final MusicTabState state;

  @override
  Widget build(BuildContext context) {
    final hasPersonalized = _hasPersonalized(state);
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
          slivers: _buildSections(
            context,
            state: state,
            hasPersonalized: hasPersonalized,
            dedupedDiscover: dedupedDiscover,
            discoverTitle: discoverTitle,
          ),
        ),
      ),
    );
  }
}

/// Tablet layout for the music tab success state.
/// Same section structure; content is constrained to a max width.
class MusicTabletLayout extends StatelessWidget {
  const MusicTabletLayout({super.key, required this.state});

  final MusicTabState state;

  static const double _contentMaxWidth = 1200.0;

  @override
  Widget build(BuildContext context) {
    final hasPersonalized = _hasPersonalized(state);
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
          toolbarHeight: 56,
          forceElevated: innerBoxIsScrolled,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 24, right: 8),
            child: Text(
              musicTabAppBarTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: CustomScrollView(
              slivers: _buildSections(
                context,
                state: state,
                hasPersonalized: hasPersonalized,
                dedupedDiscover: dedupedDiscover,
                discoverTitle: discoverTitle,
                isTablet: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared section builder ────────────────────────────────────────────────────

bool _hasPersonalized(MusicTabState state) =>
    state.recentlyPlayed.isNotEmpty ||
    state.newReleases.isNotEmpty ||
    state.discoverRelated.isNotEmpty ||
    state.trending.isNotEmpty ||
    state.featuredChannels.isNotEmpty ||
    state.featuredPlaylists.isNotEmpty ||
    state.isNewReleasesLoading ||
    state.isDiscoverLoading ||
    state.isTrendingLoading ||
    state.isFeaturedChannelsLoading ||
    state.isFeaturedPlaylistsLoading;

List<Widget> _buildSections(
  BuildContext context, {
  required MusicTabState state,
  required bool hasPersonalized,
  required List<dynamic> dedupedDiscover,
  String? discoverTitle,
  bool isTablet = false,
}) {
  return [
    // ── 0a. Explore by Mood ────────────────────────────────────────────
    MusicMoodExploreSection(isTablet: isTablet),

    // ── 0b. Explore by Genre ──────────────────────────────────────────
    MusicGenreExploreSection(isTablet: isTablet),

    // ── 0c. Featured Channels ──────────────────────────────────────────
    if (state.isFeaturedChannelsLoading) ...[
      const SkeletonSectionHeader(),
      const SkeletonChannelRow(),
    ] else if (state.featuredChannels.isNotEmpty) ...[
      const MusicSectionHeader(title: musicSectionFeaturedChannels),
      MusicFeaturedChannelsSection(channels: state.featuredChannels),
    ],

    // ── 0c. Featured Playlists ─────────────────────────────────────────
    if (state.isFeaturedPlaylistsLoading) ...[
      const SkeletonSectionHeader(),
      const SkeletonFeaturedPlaylistsRow(),
    ] else if (state.featuredPlaylists.isNotEmpty) ...[
      const MusicSectionHeader(title: musicSectionFeaturedPlaylists),
      MusicFeaturedPlaylistsSection(playlists: state.featuredPlaylists),
    ],

    // ── 0d. Continue Listening ─────────────────────────────────────────
    if (state.recentlyPlayed.isNotEmpty) ...[
      MusicSectionHeader(
        title: musicSectionContinueListening,
        onSeeAll: state.recentlyPlayed.length > 5
            ? () => isTablet
                ? showMusicSeeAllSideSheet(
                    context,
                    title: musicSectionContinueListening,
                    videos: state.recentlyPlayed,
                  )
                : showMusicSeeAllSheet(
                    context,
                    title: musicSectionContinueListening,
                    videos: state.recentlyPlayed,
                  )
            : null,
      ),
      MusicHorizontalVideoList(videos: state.recentlyPlayed),
    ],

    // ── 1. New Releases ────────────────────────────────────────────────
    if (state.isNewReleasesLoading) ...[
      const SkeletonSectionHeader(),
      const SkeletonHorizontalCards(),
    ] else if (state.newReleases.isNotEmpty) ...[
      MusicSectionHeader(
        title: musicSectionNewReleases,
        onSeeAll: state.newReleases.length > 5
            ? () => isTablet
                ? showMusicSeeAllSideSheet(
                    context,
                    title: musicSectionNewReleases,
                    videos: state.newReleases,
                  )
                : showMusicSeeAllSheet(
                    context,
                    title: musicSectionNewReleases,
                    videos: state.newReleases,
                  )
            : null,
      ),
      MusicHorizontalVideoList(videos: state.newReleases),
    ],

    // ── 2. Discover ────────────────────────────────────────────────────
    if (state.isDiscoverLoading) ...[
      const SkeletonSectionHeader(),
      const SkeletonHorizontalCards(),
    ] else if (state.discoverVideo != null && dedupedDiscover.isNotEmpty) ...[
      MusicSectionHeader(
        title: discoverTitle!,
        onSeeAll: dedupedDiscover.length > 5
            ? () => isTablet
                ? showMusicSeeAllSideSheet(
                    context,
                    title: discoverTitle,
                    videos: dedupedDiscover.cast(),
                  )
                : showMusicSeeAllSheet(
                    context,
                    title: discoverTitle,
                    videos: dedupedDiscover.cast(),
                  )
            : null,
      ),
      MusicHorizontalVideoList(videos: dedupedDiscover.cast()),
    ],

    // ── 3. Trending ────────────────────────────────────────────────────
    if (state.isTrendingLoading) ...[
      const SkeletonSectionHeader(),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        // On tablet the "See all" lives inside MusicTrendingTabletSection.
        onSeeAll: !isTablet && state.trending.length > 5
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
      if (isTablet)
        MusicTrendingTabletSection(
          trending: state.trending,
          onSeeAll: state.trending.length > 5
              ? () => showMusicSeeAllSideSheet(
                    context,
                    title: state.isInternationalTrending
                        ? musicSectionInternationalTopHits
                        : musicSectionTrendingMusic,
                    videos: state.trending,
                    ranked: true,
                  )
              : null,
        )
      else ...[
        SliverToBoxAdapter(
          child: MusicTrendingHeroCard(video: state.trending.first),
        ),
        if (state.trending.length > 1)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final video = state.trending[index + 1];
                return MusicRankedTile(rank: index + 2, video: video);
              },
              childCount: (state.trending.length - 1).clamp(0, 4),
            ),
          ),
      ],
    ],

    // ── Empty hint ─────────────────────────────────────────────────────
    if (!hasPersonalized)
      const SliverFillRemaining(
        hasScrollBody: false,
        child: MusicEmptyState(),
      ),
  ];
}

import 'package:flutter/material.dart';
import 'package:my_tube/ui/skeletons/custom_shimmer.dart';
import 'package:my_tube/utils/constants.dart';

/// Skeleton personalizzato per liste e grid di video/contenuti
class CustomSkeletonGridList extends StatelessWidget {
  const CustomSkeletonGridList({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isTablet = constraints.maxWidth > 600;

      if (isTablet) {
        // Grid per tablet
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: 20,
          itemBuilder: (context, index) {
            return _buildSkeletonGridItem();
          },
        );
      } else {
        // Lista per smartphone
        return ListView.builder(
          itemCount: 15,
          itemBuilder: (context, index) {
            return _buildSkeletonListItem();
          },
        );
      }
    });
  }

  Widget _buildSkeletonGridItem() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail del video
          const Expanded(
            flex: 3,
            child: ShimmerImage(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12,
            ),
          ),
          const SizedBox(height: 8),
          // Titolo (2 righe)
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerText(width: double.infinity, height: 14),
                SizedBox(height: 4),
                ShimmerText(width: 120, height: 12),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Nome canale (senza avatar, solo testo)
          const ShimmerText(width: 100, height: 12),
        ],
      ),
    );
  }

  Widget _buildSkeletonListItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail - corretto per VideoTile (90px width)
          const ShimmerImage(
            width: 90,
            height: 68,
            borderRadius: 8,
          ),
          const SizedBox(width: 12),
          // Contenuto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titolo (2 righe)
                const ShimmerText(width: double.infinity, height: 16),
                const SizedBox(height: 4),
                const ShimmerText(width: 200, height: 16),
                const SizedBox(height: 8),
                // Nome canale (senza avatar, solo testo)
                const ShimmerText(width: 150, height: 12),
                const SizedBox(height: 4),
                // Views e durata
                const ShimmerText(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton per mini player
class CustomSkeletonMiniPlayer extends StatelessWidget {
  const CustomSkeletonMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      child: Container(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        height: miniPlayerHeight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              // Thumbnail - dimensioni corrette per il ConstrainedBox del MiniPlayer
              const ShimmerImage(width: 64, height: 36, borderRadius: 8),
              const SizedBox(width: 8),
              // Info
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerText(width: double.infinity, height: 14),
                    SizedBox(height: 4),
                    ShimmerText(width: 120, height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Play/Pause Button
              const ShimmerCircle(size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for channel view — matches the SliverAppBar-based layout
class CustomSkeletonChannel extends StatefulWidget {
  const CustomSkeletonChannel({
    super.key,
    this.showVideoCount = 8,
    this.enableStaggerAnimation = true,
  });

  final int showVideoCount;
  final bool enableStaggerAnimation;

  @override
  State<CustomSkeletonChannel> createState() => _CustomSkeletonChannelState();
}

class _CustomSkeletonChannelState extends State<CustomSkeletonChannel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 720;
    final headerHeight = isCompact ? 200.0 : 240.0;
    final avatarSize = isCompact ? 64.0 : 80.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Collapsible header area ──────────────────────────────
            SizedBox(
              height: headerHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner shimmer
                  const ShimmerImage(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 0,
                  ),
                  // Avatar + info anchored to bottom-left
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShimmerCircle(size: avatarSize),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              ShimmerText(width: 160, height: 20),
                              SizedBox(height: 8),
                              ShimmerText(width: 100, height: 13),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Action buttons row ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: const [
                  Expanded(
                      child: ShimmerButton(width: double.infinity, height: 40)),
                  SizedBox(width: 8),
                  Expanded(
                      child: ShimmerButton(width: double.infinity, height: 40)),
                ],
              ),
            ),

            // ── Tab bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  ShimmerText(width: 60, height: 14),
                  SizedBox(width: 24),
                  ShimmerText(width: 52, height: 14),
                  SizedBox(width: 24),
                  ShimmerText(width: 68, height: 14),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Video list ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.showVideoCount,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 500 + (index * 80)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - value)),
                        child: _buildSkeletonListItem(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonListItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerImage(width: 120, height: 68, borderRadius: 8),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerText(width: double.infinity, height: 15),
              SizedBox(height: 6),
              ShimmerText(width: 180, height: 15),
              SizedBox(height: 8),
              ShimmerText(width: 120, height: 12),
              SizedBox(height: 4),
              ShimmerText(width: 100, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

/// Enhanced skeleton for playlist view with modern card-based layout
/// Skeleton for playlist view — matches the SliverAppBar-based layout
class CustomSkeletonPlaylist extends StatefulWidget {
  const CustomSkeletonPlaylist({
    super.key,
    this.showVideoCount = 8,
    this.enableStaggerAnimation = true,
  });

  final int showVideoCount;
  final bool enableStaggerAnimation;

  @override
  State<CustomSkeletonPlaylist> createState() => _CustomSkeletonPlaylistState();
}

class _CustomSkeletonPlaylistState extends State<CustomSkeletonPlaylist>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 720;
    final headerHeight = isCompact ? 220.0 : 260.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Collapsible header area ──────────────────────────
            SizedBox(
              height: headerHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail shimmer (16:9 fills the header)
                  const ShimmerImage(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 0,
                  ),
                  // Title + metadata anchored to bottom-left
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        ShimmerText(width: 200, height: 20),
                        SizedBox(height: 8),
                        ShimmerText(width: 220, height: 20),
                        SizedBox(height: 8),
                        // video count + author row
                        Row(children: [
                          ShimmerText(width: 70, height: 13),
                          SizedBox(width: 12),
                          ShimmerText(width: 110, height: 13),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Action buttons row ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: const [
                  Expanded(
                      child: ShimmerButton(width: double.infinity, height: 40)),
                  SizedBox(width: 8),
                  Expanded(
                      child: ShimmerButton(width: double.infinity, height: 40)),
                ],
              ),
            ),

            // ── Video list ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.showVideoCount,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 500 + (index * 80)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - value)),
                      child: _buildSkeletonListItem(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonListItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerImage(width: 120, height: 68, borderRadius: 8),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerText(width: double.infinity, height: 15),
              SizedBox(height: 6),
              ShimmerText(width: 180, height: 15),
              SizedBox(height: 8),
              ShimmerText(width: 150, height: 12),
              SizedBox(height: 4),
              ShimmerText(width: 120, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

/// Skeleton per la home music
class CustomSkeletonMusicHome extends StatelessWidget {
  const CustomSkeletonMusicHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          // AppBar skeleton
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            automaticallyImplyLeading: false,
            toolbarHeight: 48,
            titleSpacing: 0,
            backgroundColor: Colors.transparent,
            title: const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: ShimmerText(width: 80, height: 22),
            ),
          ),

          // Section 0a: Explore by Genre
          const SkeletonSectionHeader(),
          const _SkeletonGenreChips(),
          // Section 0b: Featured Channels
          const SkeletonSectionHeader(),
          const SkeletonChannelRow(),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),

          // Section 0c: Continue Listening
          const SkeletonSectionHeader(),
          const SkeletonHorizontalCards(),
          // Section 1: New Releases
          const SkeletonSectionHeader(),
          const SkeletonHorizontalCards(),
          // Section 2: Discover
          const SkeletonSectionHeader(),
          const SkeletonHorizontalCards(),
          // Section 3: Trending
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
        ],
      ),
    );
  }
}

class SkeletonSectionHeader extends StatelessWidget {
  const SkeletonSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 8, 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const ShimmerText(width: 160, height: 18),
          ],
        ),
      ),
    );
  }
}

class SkeletonHorizontalCards extends StatelessWidget {
  const SkeletonHorizontalCards({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final cardHeight = isTablet ? 210.0 : 175.0;
    final cardWidth = isTablet ? 290.0 : 240.0;
    return SliverToBoxAdapter(
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: cardHeight,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: double.infinity,
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _SkeletonVideoCard(width: cardWidth, height: cardHeight),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonVideoCard extends StatelessWidget {
  const _SkeletonVideoCard({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final thumbHeight = width * 9 / 16;
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerImage(width: width, height: thumbHeight, borderRadius: 8),
          const SizedBox(height: 8),
          const ShimmerText(width: double.infinity, height: 14),
          const SizedBox(height: 4),
          const ShimmerText(width: 100, height: 12),
        ],
      ),
    );
  }
}

class SkeletonTrendingHero extends StatelessWidget {
  const SkeletonTrendingHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail 16:9
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ShimmerImage(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
            ),
          ),
          // Info row: rank badge + title + artist
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerText(width: 36, height: 24, borderRadius: 8),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerText(width: double.infinity, height: 14),
                      SizedBox(height: 4),
                      ShimmerText(width: 120, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonRankedTile extends StatelessWidget {
  const SkeletonRankedTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShimmerText(width: 28, height: 14),
          SizedBox(width: 8),
          ShimmerImage(width: 120, height: 68, borderRadius: 4),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerText(width: double.infinity, height: 14),
                SizedBox(height: 4),
                ShimmerText(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonChannelRow extends StatelessWidget {
  const SkeletonChannelRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, __) => const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerCircle(size: 72),
              SizedBox(height: 6),
              ShimmerText(width: 56, height: 11),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonFeaturedPlaylistsRow extends StatelessWidget {
  const SkeletonFeaturedPlaylistsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 720;
    final cardHeight = isCompact ? 180.0 : 220.0;
    final cardWidth = isCompact ? 180.0 : 240.0;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: cardHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, __) => SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ShimmerImage(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: isCompact ? 12 : 16,
                  ),
                ),
                const SizedBox(height: 8),
                const ShimmerText(width: double.infinity, height: 14),
                const SizedBox(height: 4),
                const ShimmerText(width: 80, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonGenreChips extends StatelessWidget {
  const _SkeletonGenreChips();

  @override
  Widget build(BuildContext context) {
    const widths = [60.0, 76.0, 52.0, 68.0, 84.0, 56.0];
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widths.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => ShimmerButton(
            width: widths[i],
            height: 32,
            borderRadius: 20,
          ),
        ),
      ),
    );
  }
}

/// Enhanced skeleton for action buttons with loading states
class SkeletonActionButton extends StatelessWidget {
  const SkeletonActionButton({
    super.key,
    this.width = 120,
    this.height = 40,
    this.isPrimary = true,
  });

  final double width;
  final double height;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isPrimary
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
      ),
      child: CustomShimmer(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Enhanced skeleton for download progress
class SkeletonDownloadProgress extends StatefulWidget {
  const SkeletonDownloadProgress({super.key});

  @override
  State<SkeletonDownloadProgress> createState() =>
      _SkeletonDownloadProgressState();
}

class _SkeletonDownloadProgressState extends State<SkeletonDownloadProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const ShimmerCircle(size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: ShimmerText(width: double.infinity, height: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor:
                    theme.colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ShimmerText(width: 60, height: 12),
              const ShimmerText(width: 40, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

/// Enhanced skeleton for error state with retry button
class SkeletonErrorState extends StatelessWidget {
  const SkeletonErrorState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 24),
          const ShimmerText(width: 200, height: 24),
          const SizedBox(height: 12),
          const ShimmerText(width: 300, height: 16),
          const SizedBox(height: 8),
          const ShimmerText(width: 250, height: 16),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SkeletonActionButton(width: 100, height: 40),
              const SizedBox(width: 16),
              SkeletonActionButton(
                width: 100,
                height: 40,
                isPrimary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Enhanced skeleton for empty state
class SkeletonEmptyState extends StatelessWidget {
  const SkeletonEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          const ShimmerText(width: 180, height: 24),
          const SizedBox(height: 12),
          const ShimmerText(width: 280, height: 16),
          const SizedBox(height: 8),
          const ShimmerText(width: 200, height: 16),
          const SizedBox(height: 32),
          const SkeletonActionButton(
            width: 120,
            height: 40,
            isPrimary: false,
          ),
        ],
      ),
    );
  }
}

/// Skeleton for loading more content at the bottom of lists
class SkeletonLoadingMore extends StatefulWidget {
  const SkeletonLoadingMore({super.key});

  @override
  State<SkeletonLoadingMore> createState() => _SkeletonLoadingMoreState();
}

class _SkeletonLoadingMoreState extends State<SkeletonLoadingMore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _pulseAnimation.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const ShimmerText(width: 120, height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

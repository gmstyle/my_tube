import 'package:flutter/material.dart';
import 'package:my_tube/ui/skeletons/custom_shimmer.dart';

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
        height: 72,
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

/// Enhanced skeleton for channel view with modern card-based layout
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Enhanced channel header skeleton with stagger
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildEnhancedChannelHeaderSkeleton(context),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Video list skeleton with stagger
            _buildAnimatedVideoListSkeleton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedChannelHeaderSkeleton(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 720;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isCompact
              ? _buildCompactChannelHeaderSkeleton(context)
              : _buildExpandedChannelHeaderSkeleton(context),
        ),
      ),
    );
  }

  Widget _buildCompactChannelHeaderSkeleton(BuildContext context) {
    return Column(
      children: [
        // Avatar
        const ShimmerCircle(size: 80),
        const SizedBox(height: 16),
        // Channel info
        Column(
          children: [
            // Channel name (2 lines)
            const ShimmerText(width: double.infinity, height: 24),
            const SizedBox(height: 8),
            const ShimmerText(width: 200, height: 24),
            const SizedBox(height: 12),
            // Subscriber count
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ShimmerCircle(size: 16),
                const SizedBox(width: 6),
                const ShimmerText(width: 120, height: 14),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Action buttons container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Expanded(
                child: ShimmerButton(width: double.infinity, height: 40),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: ShimmerButton(width: double.infinity, height: 40),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedChannelHeaderSkeleton(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        const ShimmerCircle(size: 96),
        const SizedBox(width: 24),
        // Content section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Channel name (2 lines)
              const ShimmerText(width: double.infinity, height: 24),
              const SizedBox(height: 8),
              const ShimmerText(width: 250, height: 24),
              const SizedBox(height: 12),
              // Subscriber count
              Row(
                children: [
                  const ShimmerCircle(size: 16),
                  const SizedBox(width: 6),
                  const ShimmerText(width: 120, height: 14),
                ],
              ),
              const SizedBox(height: 20),
              // Action buttons container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const ShimmerButton(width: 120, height: 40),
                    const SizedBox(width: 12),
                    const ShimmerButton(width: 140, height: 40),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonListItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        const ShimmerImage(
          width: 90,
          height: 68,
          borderRadius: 8,
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title (2 lines)
              const ShimmerText(width: double.infinity, height: 16),
              const SizedBox(height: 4),
              const ShimmerText(width: 200, height: 16),
              const SizedBox(height: 8),
              // Channel name
              const ShimmerText(width: 150, height: 12),
              const SizedBox(height: 4),
              // Views and duration
              const ShimmerText(width: 120, height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedVideoListSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 800 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildSkeletonListItem(),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }
}

/// Enhanced skeleton for playlist view with modern card-based layout
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Enhanced playlist header skeleton with stagger
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildEnhancedPlaylistHeaderSkeleton(context),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Video list skeleton with stagger
            _buildAnimatedVideoListSkeleton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPlaylistHeaderSkeleton(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 720;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: isCompact
            ? _buildStackedHeaderSkeleton(context)
            : _buildSideBySideHeaderSkeleton(context),
      ),
    );
  }

  Widget _buildStackedHeaderSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image section
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ShimmerImage(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
              ),
              // Video count badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const ShimmerText(width: 40, height: 14),
                ),
              ),
            ],
          ),
        ),
        // Content section
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const ShimmerText(width: double.infinity, height: 24),
              const SizedBox(height: 8),
              const ShimmerText(width: 250, height: 24),
              const SizedBox(height: 16),
              // Metadata row
              Row(
                children: [
                  const ShimmerCircle(size: 20),
                  const SizedBox(width: 8),
                  const ShimmerText(width: 80, height: 16),
                  const SizedBox(width: 16),
                  const ShimmerCircle(size: 18),
                  const SizedBox(width: 6),
                  const Flexible(
                    child: ShimmerText(width: 120, height: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action buttons
              Row(
                children: [
                  const Expanded(
                    child: ShimmerButton(width: double.infinity, height: 40),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: ShimmerButton(width: double.infinity, height: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideBySideHeaderSkeleton(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image section
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ShimmerImage(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 0,
                  ),
                  // Video count badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const ShimmerText(width: 40, height: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const ShimmerText(width: double.infinity, height: 24),
                  const SizedBox(height: 8),
                  const ShimmerText(width: 200, height: 24),
                  const SizedBox(height: 16),
                  // Metadata row
                  Row(
                    children: [
                      const ShimmerCircle(size: 20),
                      const SizedBox(width: 8),
                      const ShimmerText(width: 80, height: 16),
                      const SizedBox(width: 16),
                      const ShimmerCircle(size: 18),
                      const SizedBox(width: 6),
                      const Flexible(
                        child: ShimmerText(width: 120, height: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      const Expanded(
                        child:
                            ShimmerButton(width: double.infinity, height: 40),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child:
                            ShimmerButton(width: double.infinity, height: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonListItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        const ShimmerImage(
          width: 90,
          height: 68,
          borderRadius: 8,
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title (2 lines)
              const ShimmerText(width: double.infinity, height: 16),
              const SizedBox(height: 4),
              const ShimmerText(width: 200, height: 16),
              const SizedBox(height: 8),
              // Channel name
              const ShimmerText(width: 150, height: 12),
              const SizedBox(height: 4),
              // Views and duration
              const ShimmerText(width: 120, height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedVideoListSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 800 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildSkeletonListItem(),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }
}

/// Skeleton per la home music
class CustomSkeletonMusicHome extends StatelessWidget {
  const CustomSkeletonMusicHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sezione "Ascoltati di recente"
          _buildMusicSection("Ascoltati di recente"),
          const SizedBox(height: 20),
          // Sezione "Mix per te"
          _buildMusicSection("Mix per te"),
          const SizedBox(height: 20),
          // Sezione "Artisti consigliati"
          _buildMusicSection("Artisti consigliati"),
        ],
      ),
    );
  }

  Widget _buildMusicSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo sezione
        const ShimmerText(width: 200, height: 18),
        const SizedBox(height: 12),
        // Lista orizzontale
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerImage(
                      width: double.infinity,
                      height: 120,
                      borderRadius: 8,
                    ),
                    SizedBox(height: 8),
                    ShimmerText(width: double.infinity, height: 14),
                    SizedBox(height: 4),
                    ShimmerText(width: 100, height: 12),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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

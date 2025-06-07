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
        height: 80,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              // Thumbnail - dimensioni corrette per il ConstrainedBox del MiniPlayer
              const ShimmerImage(width: 64, height: 64, borderRadius: 8),
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

/// Skeleton per canali
class CustomSkeletonChannel extends StatelessWidget {
  const CustomSkeletonChannel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header del canale
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Banner
              const Expanded(
                child: ShimmerImage(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(height: 16),
              // Avatar e info
              Row(
                children: [
                  const ShimmerCircle(
                      size: 64), // Avatar più grande per header canale
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerText(width: double.infinity, height: 18),
                        SizedBox(height: 4),
                        ShimmerText(width: 150, height: 14),
                        SizedBox(height: 4),
                        ShimmerText(width: 100, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Contenuto del canale
        Expanded(
          child: CustomSkeletonGridList(),
        ),
      ],
    );
  }
}

/// Skeleton per playlist
class CustomSkeletonPlaylist extends StatelessWidget {
  const CustomSkeletonPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header playlist
        Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail playlist - dimensioni corrette
              const ShimmerImage(width: 90, height: 68, borderRadius: 8),
              const SizedBox(width: 16),
              // Info playlist
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerText(width: double.infinity, height: 18),
                    SizedBox(height: 8),
                    ShimmerText(width: 200, height: 14),
                    SizedBox(height: 8),
                    ShimmerText(width: 150, height: 12),
                    SizedBox(height: 8),
                    ShimmerText(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Lista video
        Expanded(
          child: CustomSkeletonGridList(),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/music_see_all_sheet.dart';
import 'package:my_tube/utils/constants.dart';

/// Sliver that shows mood filter chips (one selectable at a time).
/// Tapping a chip fetches videos inline and shows a horizontal card preview
/// with a "See all" button that opens a side sheet (tablet) or bottom sheet
/// (mobile) with the full list.
class MusicMoodExploreSection extends StatefulWidget {
  const MusicMoodExploreSection({super.key, this.isTablet = false});

  final bool isTablet;

  @override
  State<MusicMoodExploreSection> createState() =>
      _MusicMoodExploreSectionState();
}

class _MusicMoodExploreSectionState extends State<MusicMoodExploreSection> {
  String? _selectedLabel;
  Future<List<models.VideoTile>>? _future;

  void _onChipTap(String label, String query, YoutubeExplodeRepository repo) {
    setState(() {
      if (_selectedLabel == label) {
        // Deselect — collapse content
        _selectedLabel = null;
        _future = null;
      } else {
        _selectedLabel = label;
        _future = repo.getMoodMusic(query);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final repo = context.read<YoutubeExplodeRepository>();
    final firstMood = musicMoods.first;
    _selectedLabel = firstMood.key;
    _future = repo.getMoodMusic(firstMood.value);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<YoutubeExplodeRepository>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cardHeight = widget.isTablet ? 210.0 : 175.0;
    final cardWidth = widget.isTablet ? 290.0 : 240.0;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 20,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  musicSectionExploreByMood,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // ── Mood chips ──────────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: musicMoods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final mood = musicMoods[index];
                final label = mood.key;
                final query = mood.value;
                return FilterChip(
                  label: Text(label),
                  selected: _selectedLabel == label,
                  onSelected: (_) => _onChipTap(label, query, repo),
                );
              },
            ),
          ),
          // ── Inline loaded content ───────────────────────────────────
          if (_future != null)
            FutureBuilder<List<models.VideoTile>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return MusicHorizontalSkeletonCards(
                    cardHeight: cardHeight,
                    cardWidth: cardWidth,
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'No results for $_selectedLabel',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }
                final videos = snapshot.data!;
                final preview = videos.take(10).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sub-header with "See all"
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedLabel!,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => widget.isTablet
                                ? showMusicSeeAllSideSheet(
                                    context,
                                    title: _selectedLabel!,
                                    videos: videos,
                                  )
                                : showMusicSeeAllSheet(
                                    context,
                                    title: _selectedLabel!,
                                    videos: videos,
                                  ),
                            style: TextButton.styleFrom(
                              foregroundColor: cs.primary,
                              textStyle: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text(sectionSeeAllLabel),
                          ),
                        ],
                      ),
                    ),
                    // Horizontal video cards
                    SizedBox(
                      height: cardHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: preview.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final video = preview[index];
                          return SizedBox(
                            width: cardWidth,
                            child: PlayPauseGestureDetector(
                              id: video.id,
                              child: VideoMenuDialog(
                                quickVideo: {
                                  'id': video.id,
                                  'title': video.title,
                                },
                                child: VideoGridItem(video: video),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

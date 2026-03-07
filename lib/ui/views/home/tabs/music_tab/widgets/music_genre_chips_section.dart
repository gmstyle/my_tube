import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';

const _kMusicGenres = [
  ('Pop', 'Pop'),
  ('Hip-Hop', 'Hip Hop'),
  ('Rock', 'Rock'),
  ('R&B', 'R&B Soul'),
  ('Electronic', 'Electronic'),
  ('Latin', 'Latin'),
  ('K-Pop', 'KPop'),
  ('Jazz', 'Jazz'),
  ('Classical', 'Classical'),
];

/// Sliver with a horizontal row of genre action chips.
/// Tapping a chip opens [_GenreSheet] which lazily fetches trending videos.
class MusicGenreChipsSection extends StatelessWidget {
  const MusicGenreChipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _kMusicGenres.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final (label, query) = _kMusicGenres[index];
            return ActionChip(
              label: Text(label),
              onPressed: () {
                // Capture the repository before the async gap
                final repo = context.read<YoutubeExplodeRepository>();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  useRootNavigator: false,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) =>
                      _GenreSheet(label: label, query: query, repo: repo),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GenreSheet — bottom sheet that lazily fetches genre videos
// ─────────────────────────────────────────────────────────────────────────────

class _GenreSheet extends StatefulWidget {
  const _GenreSheet(
      {required this.label, required this.query, required this.repo});

  final String label;
  final String query;
  final YoutubeExplodeRepository repo;

  @override
  State<_GenreSheet> createState() => _GenreSheetState();
}

class _GenreSheetState extends State<_GenreSheet> {
  late final Future<List<models.VideoTile>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repo.getTrending(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<models.VideoTile>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No results for ${widget.label}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }
                  final videos = snapshot.data!;
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return PlayPauseGestureDetector(
                        id: video.id,
                        child: VideoMenuDialog(
                          quickVideo: {'id': video.id, 'title': video.title},
                          child: VideoTile(video: video),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/ui/views/common/global_search_delegate.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';

class SearchTabletLayout extends StatelessWidget {
  const SearchTabletLayout({super.key});

  static const double _contentMaxWidth = 1000.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        // ── Top AppBar ──────────────────────────────────────────────────
        Material(
          color: cs.surface,
          elevation: 0,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Search',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),

        // ── Body ────────────────────────────────────────────────────────
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: CustomScrollView(
                slivers: [
                  // ── Search bar ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: GestureDetector(
                        onTap: () => _openSearch(context),
                        child: AbsorbPointer(
                          child: SearchBar(
                            hintText: 'Search videos, music, channels...',
                            leading: const Icon(Icons.search),
                            elevation: const WidgetStatePropertyAll(0),
                            backgroundColor: WidgetStatePropertyAll(
                              cs.primaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Recent searches ──────────────────────────────────
                  BlocBuilder<SearchSuggestionCubit, SearchSuggestionState>(
                    builder: (context, state) {
                      final history = state.isQueryHistory
                          ? state.suggestions.take(5).toList()
                          : <String>[];
                      if (history.isEmpty) return const SliverToBoxAdapter();

                      return SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 32, 8, 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Recent searches',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      for (final q
                                          in List<String>.from(history)) {
                                        context
                                            .read<SearchSuggestionCubit>()
                                            .deleteQueryFromHistory(q);
                                      }
                                    },
                                    child: const Text('Clear all'),
                                  ),
                                ],
                              ),
                            ),
                            ...history.map(
                              (q) => ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                leading: const Icon(Icons.history),
                                title: Text(q),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => context
                                      .read<SearchSuggestionCubit>()
                                      .deleteQueryFromHistory(q),
                                ),
                                onTap: () => _openSearch(context, query: q),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // ── Favorite videos — recently added ─────────────────
                  BlocBuilder<FavoritesVideoBloc, FavoritesVideoState>(
                    builder: (context, state) {
                      final videos = state.videos;
                      if (state.status != FavoritesStatus.success ||
                          videos == null ||
                          videos.isEmpty) {
                        return const SliverToBoxAdapter();
                      }

                      final recent = videos.reversed.take(12).toList();

                      return SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 32, 24, 12),
                              child: Text(
                                'From your favorites',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 16 / 10,
                                ),
                                itemCount: recent.length,
                                itemBuilder: (context, index) {
                                  final VideoTile video = recent[index];
                                  return VideoMenuDialog(
                                    quickVideo: {
                                      'id': video.id,
                                      'title': video.title,
                                    },
                                    child: VideoGridItem(video: video),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openSearch(BuildContext context, {String query = ''}) async {
    final persistentUiCubit = context.read<PersistentUiCubit>();
    final searchSuggestionCubit = context.read<SearchSuggestionCubit>();
    persistentUiCubit.setSearchOpen(true);
    await showSearch(
      context: context,
      delegate: GlobalSearchDelegate(),
      query: query,
    );
    searchSuggestionCubit.getQueryHistory();
    persistentUiCubit.setSearchOpen(false);
  }
}

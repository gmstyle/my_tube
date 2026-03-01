import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/models/tiles.dart';
import 'package:my_tube/ui/views/common/global_search_delegate.dart';
import 'package:my_tube/ui/views/common/video_grid_item.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';

class SearchTabView extends StatefulWidget {
  const SearchTabView({super.key});

  @override
  State<SearchTabView> createState() => _SearchTabViewState();
}

class _SearchTabViewState extends State<SearchTabView> {
  @override
  void initState() {
    super.initState();
    context.read<SearchSuggestionCubit>().getQueryHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: GestureDetector(
                  onTap: () => _openSearch(context),
                  child: AbsorbPointer(
                    child: SearchBar(
                      hintText: 'Search videos, music, channels...',
                      leading: const Icon(Icons.search),
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Recent searches
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
                        padding: const EdgeInsets.fromLTRB(16, 24, 4, 8),
                        child: Row(
                          children: [
                            Text(
                              'Recent searches',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                for (final q in List<String>.from(history)) {
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

            // Favorite videos — recently added
            BlocBuilder<FavoritesVideoBloc, FavoritesVideoState>(
              builder: (context, state) {
                final videos = state.videos;
                if (state.status != FavoritesStatus.success ||
                    videos == null ||
                    videos.isEmpty) {
                  return const SliverToBoxAdapter();
                }

                final recent = videos.reversed.take(10).toList();

                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          'From your favorites',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: recent.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final VideoTile video = recent[index];
                            return SizedBox(
                              width: 160,
                              child: VideoMenuDialog(
                                quickVideo: {
                                  'id': video.id,
                                  'title': video.title,
                                },
                                child: VideoGridItem(video: video),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
    // Aggiorna la history al ritorno dalla ricerca

    searchSuggestionCubit.getQueryHistory();
    persistentUiCubit.setSearchOpen(false);
  }
}

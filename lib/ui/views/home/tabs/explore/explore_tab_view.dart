import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/ui/shared/responsive_layout_builder.dart';
import 'package:my_tube/ui/views/home/tabs/explore/layouts/explore_mobile_layout.dart';
import 'package:my_tube/ui/views/home/tabs/explore/layouts/explore_tablet_layout.dart';

class ExploreTabView extends StatefulWidget {
  const ExploreTabView({super.key});

  @override
  State<ExploreTabView> createState() => _ExploreTabViewState();
}

class _ExploreTabViewState extends State<ExploreTabView> {
  CategoryEnum _selectedCategory = CategoryEnum.now;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ExploreTabBloc>()
          .add(GetTrendingVideos(category: _selectedCategory));
    });
  }

  void _selectCategory(CategoryEnum cat) {
    if (cat == _selectedCategory) return;
    setState(() => _selectedCategory = cat);
    context.read<ExploreTabBloc>().add(GetTrendingVideos(category: cat));
  }

  String _labelFor(CategoryEnum c) {
    switch (c) {
      case CategoryEnum.now:
        return 'Trending';
      case CategoryEnum.music:
        return 'Music';
      case CategoryEnum.film:
        return 'Film';
      case CategoryEnum.gaming:
        return 'Gaming';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      mobile: (_) => ExploreMobileLayout(
        selectedCategory: _selectedCategory,
        onSelectCategory: _selectCategory,
        labelFor: _labelFor,
      ),
      tablet: (_) => ExploreTabletLayout(
        selectedCategory: _selectedCategory,
        onSelectCategory: _selectCategory,
        labelFor: _labelFor,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/ui/shared/responsive_layout_builder.dart';
import 'package:my_tube/ui/views/home/tabs/search/layouts/search_mobile_layout.dart';
import 'package:my_tube/ui/views/home/tabs/search/layouts/search_tablet_layout.dart';

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
    return ResponsiveLayoutBuilder(
      mobile: (_) => const SearchMobileLayout(),
      tablet: (_) => const SearchTabletLayout(),
    );
  }
}

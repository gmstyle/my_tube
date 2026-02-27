import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/home/tabs/search/search_tab_view.dart';

class SearchTabPage extends Page {
  const SearchTabPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return const SearchTabView();
      },
    );
  }
}

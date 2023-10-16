import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/search/search_view.dart';

class SearchPage extends Page {
  const SearchPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return SearchView();
      },
    );
  }
}

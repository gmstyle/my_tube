import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/test/test_youtube_explode_page.dart';

class TestYoutubeExplodePageWrapper extends Page {
  const TestYoutubeExplodePageWrapper({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return const TestYoutubeExplodePage();
      },
    );
  }
}

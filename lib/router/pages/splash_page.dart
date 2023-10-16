import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/splash/splash_view.dart';
import '';

class SplashPage extends Page {
  const SplashPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return SplashView();
        });
  }
}

import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/login/login_view.dart';

class LoginPage extends Page {
  const LoginPage({Key? key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return const LoginView();
        });
  }
}

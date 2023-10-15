import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/home/tabs/account_tab_view.dart';

class AccountTabPage extends Page {
  const AccountTabPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return const AccountTabView();
        });
  }
}

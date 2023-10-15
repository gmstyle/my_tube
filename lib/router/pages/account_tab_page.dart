import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/home/tabs/account_tab.dart';

class AccountTabPage extends Page {
  const AccountTabPage({Key? key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return const AccountTab();
        });
  }
}

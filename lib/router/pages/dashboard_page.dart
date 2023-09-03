import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/dashboard/dashboard_view.dart';

class DashboardPage extends Page {
  const DashboardPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return const DashboardView();
        });
  }
}

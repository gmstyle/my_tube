import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/services/download_service.dart';
import 'package:my_tube/ui/views/scaffold_with_navbar.dart';

class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavbarView(navigationShell: navigationShell);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/auth/auth_bloc.dart';
import 'package:my_tube/respositories/auth_repository.dart';
import 'package:my_tube/ui/views/dashboard/dashboard_view.dart';

class DashboardPage extends Page {
  const DashboardPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return MultiBlocProvider(providers: [
            BlocProvider<AuthBloc>(
                create: (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(const CheckIfIsLoggedIn())),
          ], child: const DashboardView());
        });
  }
}

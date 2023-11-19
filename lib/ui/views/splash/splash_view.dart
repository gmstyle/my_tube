import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/auth/auth_bloc.dart';
import 'package:my_tube/router/app_router.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.goNamed(AppRoute.explore.name);
        }

        if (state.status == AuthStatus.unauthenticated) {
          context.goNamed(AppRoute.login.name);
        }
      },
      child: const Center(
        child: SizedBox(width: 100, height: 100, child: FlutterLogo()),
      ),
    );
  }
}

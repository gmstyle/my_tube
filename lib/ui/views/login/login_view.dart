import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/router/app_router.dart';

import '../../../blocs/auth/auth_bloc.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.goNamed(AppRoute.explore.name);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LoginView'),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.status == AuthStatus.unknown) {
              //TODO: Fare un loader migliore
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const SignIn());
                  },
                  child: const Text('Login'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

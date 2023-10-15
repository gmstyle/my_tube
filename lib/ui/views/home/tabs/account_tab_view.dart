import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/auth/auth_bloc.dart';
import 'package:my_tube/router/app_router.dart';

class AccountTabView extends StatelessWidget {
  const AccountTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.goNamed(AppRoute.login.name);
        }
      },
      builder: (context, state) {
        if (state.status == AuthStatus.unknown) {
          //TODO: Fare un loader migliore
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Center(
            child: ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const SignOut());
                },
                child: const Text('Sign Out')));
      },
    );
  }
}

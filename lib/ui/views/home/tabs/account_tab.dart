import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/auth/auth_bloc.dart';
import 'package:my_tube/router/app_router.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.goNamed(AppRoute.login.name);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.unknown) {
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
      ),
    );
  }
}

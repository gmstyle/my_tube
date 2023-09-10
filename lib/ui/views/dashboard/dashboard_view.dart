import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/auth/auth_bloc.dart';
import 'package:my_tube/ui/views/login/login_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.authenticated:
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const SignOut());
                  },
                  child: const Text('Logout'),
                ),
              );
            case AuthStatus.unauthenticated:
              return LoginView();
            case AuthStatus.unknown:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

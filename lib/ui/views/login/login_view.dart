import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/auth/auth_bloc.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoginView'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<AuthBloc>().add(const SignIn());
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}

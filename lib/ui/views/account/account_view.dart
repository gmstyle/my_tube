import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/playcustomapp/v1.dart';
import 'package:my_tube/blocs/auth/auth_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/home/my_account_tab/my_account_bloc.dart';
import 'package:my_tube/respositories/queue_repository.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/resource_tile.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainGradient(
        child: Scaffold(
      appBar: const CustomAppbar(
        title: 'My Tube',
      ),
      backgroundColor: Colors.transparent,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            context.goNamed(AppRoute.login.name);
          }
        },
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
    ));
  }
}

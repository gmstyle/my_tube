import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/auth/auth_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/home/my_account_tab/my_account_bloc.dart';
import 'package:my_tube/respositories/queue_repository.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/resource_tile.dart';

class AccountTabView extends StatelessWidget {
  const AccountTabView({super.key});

  @override
  Widget build(BuildContext context) {
    /* return BlocConsumer<AuthBloc, AuthState>(
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
    ); */

    final queueRepository = context.read<MyAccountBloc>().queueRepository;
    //queueRepository.clear();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.goNamed(AppRoute.login.name);
        }
      },
      child: Column(
        children: [
          /// User info header

          // Button to sign out
          BlocBuilder<AuthBloc, AuthState>(
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

          // Queue
          ValueListenableBuilder(
              valueListenable: queueRepository.queueListenable,
              builder: (context, box, _) {
                final queue = box.values.toList();

                if (queue.isEmpty) {
                  return const Center(
                    child: Text('No videos in queue'),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      queue.sort((b, a) => a.addedAt!.compareTo(b.addedAt!));
                      final video = queue[index];
                      return GestureDetector(
                          onTap: () async {
                            await context
                                .read<MiniPlayerCubit>()
                                .startPlaying(video.id!);
                          },
                          child: ResourceTile(resource: video));
                    },
                  ),
                );
              })
        ],
      ),
    );
  }
}

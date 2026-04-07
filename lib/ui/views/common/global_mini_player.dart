import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/ui/views/common/mini_player.dart';

class GlobalMiniPlayer extends StatefulWidget {
  const GlobalMiniPlayer({super.key});

  @override
  State<GlobalMiniPlayer> createState() => _GlobalMiniPlayerState();
}

class _GlobalMiniPlayerState extends State<GlobalMiniPlayer> {
  StreamSubscription<({String id, String title})>? _errorSubscription;

  @override
  void initState() {
    super.initState();
    final service = context.read<PlayerCubit>().mtPlayerService;
    _errorSubscription = service.onPlayError.listen((event) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossibile riprodurre: ${event.title}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, playerState) {
        if (playerState.status == PlayerStatus.hidden) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<PersistentUiCubit, PersistentUiState>(
          builder: (context, uiState) {
            if (!uiState.isPlayerVisible) {
              return const SizedBox.shrink();
            }

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: uiState.leftPadding,
              right: 0,
              bottom: uiState.bottomPadding,
              child: Material(
                color: Colors.transparent,
                child: const MiniPlayer(),
              ),
            );
          },
        );
      },
    );
  }
}

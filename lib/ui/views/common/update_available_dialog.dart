import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/update_bloc/update_bloc.dart';
import 'package:my_tube/models/update.dart';
import 'package:my_tube/utils/constants.dart';

class UpdateAvailableDialog extends StatelessWidget {
  const UpdateAvailableDialog({super.key, required this.update});

  final Update update;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(updateDialogTitle),
      content: SingleChildScrollView(
        child: BlocBuilder<UpdateBloc, UpdateState>(
          builder: (context, state) {
            if (state.status == UpdateStatus.downloading) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(updateDialogDownloadingMessage),
                  SizedBox(height: 16),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (state.status == UpdateStatus.failure) {
              if (state.errorMessage!.contains('Permission')) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(updateDialogPermissionMissingMessage),
                  ],
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        '$updateDialogDownloadFailurePrefix${state.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text(actionCloseLabel),
                    ),
                  ],
                );
              }
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$updateDialogAvailableVersionPrefix${update.releaseVersion}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text('$updateDialogChangelogPrefix${update.changeLog}'),
              ],
            );
          },
        ),
      ),
      actions: [
        BlocBuilder<UpdateBloc, UpdateState>(
          builder: (context, state) {
            if (state.status != UpdateStatus.downloading) {
              return TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text(actionCancelLabel),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        BlocBuilder<UpdateBloc, UpdateState>(
          builder: (context, state) {
            if (state.status != UpdateStatus.downloading) {
              return ElevatedButton(
                onPressed: () {
                  context.read<UpdateBloc>().add(
                      InstallUpdate(releaseVersion: update.releaseVersion));
                },
                child: const Text(updateDialogDownloadActionLabel),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

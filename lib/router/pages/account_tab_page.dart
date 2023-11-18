import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/my_account_tab/my_account_bloc.dart';
import 'package:my_tube/respositories/queue_repository.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/ui/views/home/tabs/account_tab_view.dart';

class AccountTabPage extends Page {
  const AccountTabPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return MultiBlocProvider(providers: [
            BlocProvider<MyAccountBloc>(
                create: (context) => MyAccountBloc(
                    youtubeRepository: context.read<YoutubeRepository>(),
                    queueRepository: context.read<QueueRepository>())
                  ..add(GetQueue()))
          ], child: const AccountTabView());
        });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/my_account/my_account_bloc.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/ui/views/account/account_view.dart';

class AccountPage extends Page {
  const AccountPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return MultiBlocProvider(providers: [
            BlocProvider<MyAccountBloc>(
                create: (context) => MyAccountBloc(
                      youtubeRepository: context.read<YoutubeRepository>(),
                    ))
          ], child: const AccountView());
        });
  }
}

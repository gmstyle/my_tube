import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/subscription_tab/subscription_bloc.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/ui/views/home/tabs/subscription_tab_view.dart';

class SubscriptionsTabPAge extends Page {
  const SubscriptionsTabPAge({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return MultiBlocProvider(providers: [
            BlocProvider<SubscriptionBloc>(
                create: (_) => SubscriptionBloc(
                    youtubeRepository: context.read<YoutubeRepository>())
                  ..add(const GetSubscriptions())),
          ], child: SubscriptionTabView());
        });
  }
}

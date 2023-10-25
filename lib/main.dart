import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/blocs/auth/auth_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/providers/auth_provider.dart';
import 'package:my_tube/providers/youtube_provider.dart';
import 'package:my_tube/respositories/auth_repository.dart';
import 'package:my_tube/respositories/mappers/subscription_mapper.dart';
import 'package:my_tube/respositories/mappers/search_mapper.dart';
import 'package:my_tube/respositories/mappers/video_mapper.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/utils/notification_controller.dart';
import 'package:provider/provider.dart';

import 'app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');

  await NotificationController.init();
  await NotificationController.interceptInitialCallActionRequest();

  /// Bloc observer
  Bloc.observer = AppBlocObserver();

  runApp(MultiProvider(
    providers: [
      /// Providers
      Provider<AuthProvider>(create: (context) => AuthProvider()),
      Provider<YoutubeProvider>(create: (context) => YoutubeProvider()),
    ],
    child: MultiProvider(
      providers: [
        /// Mappers
        Provider<VideoMapper>(create: (context) => VideoMapper()),
        Provider<SearchMapper>(create: (context) => SearchMapper()),
        Provider<SubscriptionMapper>(create: (context) => SubscriptionMapper()),
      ],
      child: MultiRepositoryProvider(
        /// Repositories
        providers: [
          RepositoryProvider<AuthRepository>(
            create: (context) =>
                AuthRepository(authProvider: context.read<AuthProvider>()),
          ),
          RepositoryProvider<YoutubeRepository>(
            create: (context) => YoutubeRepository(
                youtubeProvider: context.read<YoutubeProvider>(),
                videoMapper: context.read<VideoMapper>(),
                searchMapper: context.read<SearchMapper>(),
                activityMapper: context.read<SubscriptionMapper>()),
          ),
        ],
        child: MultiBlocProvider(providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>())
                  ..add(const CheckIfIsLoggedIn()),
          ),
          BlocProvider<MiniPlayerCubit>(
              create: (context) => MiniPlayerCubit(
                    youtubeRepository: context.read<YoutubeRepository>(),
                  )),
        ], child: const MyApp()),
      ),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router;

    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

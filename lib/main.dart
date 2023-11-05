import 'package:audio_service/audio_service.dart';
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
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:provider/provider.dart';

import 'app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  final mtPlayerHandler = await AudioService.init(
      builder: () => MtPlayerHandler(),
      config: const AudioServiceConfig(
          //androidNotificationChannelId: 'mytube_channel',
          //androidNotificationChannelName: 'MyTube',
          androidNotificationOngoing: true));

  /// Bloc observer
  Bloc.observer = AppBlocObserver();

  runApp(MultiProvider(
    providers: [
      /// Providers
      Provider<AuthProvider>(create: (context) => AuthProvider()),
      Provider<YoutubeProvider>(create: (context) => YoutubeProvider()),
      Provider<MtPlayerHandler>(create: (context) => mtPlayerHandler),
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
                subscriptionMapper: context.read<SubscriptionMapper>()),
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
                    mtPlayerHandler: context.read<MtPlayerHandler>(),
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

    const mainColor = Color.fromARGB(255, 66, 24, 150);

    return MaterialApp.router(
      title: 'My Tube',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: mainColor),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

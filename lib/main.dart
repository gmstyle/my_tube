import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_bloc.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/providers/innertube_provider.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/respositories/favorites_repository.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:provider/provider.dart';

import 'app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Force portrait mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Hive.initFlutter();
  Hive.registerAdapter(ResourceMTAdapter());
  await Hive.openBox('settings');
  await Hive.openBox<ResourceMT>('favorites');

  final mtPlayerService = await AudioService.init(
      builder: () => MtPlayerService(),
      config: const AudioServiceConfig(
          androidNotificationChannelId: 'mytube_channel',
          androidNotificationChannelName: 'MyTube',
          androidNotificationOngoing: true));

  /// Bloc observer
  Bloc.observer = AppBlocObserver();

  runApp(MultiProvider(
    providers: [
      /// Providers

      Provider<InnertubeProvider>(create: (context) => InnertubeProvider()),
      Provider<MtPlayerService>(create: (context) => mtPlayerService),
    ],
    child: MultiRepositoryProvider(
      /// Repositories
      providers: [
        RepositoryProvider<InnertubeRepository>(
            create: (context) => InnertubeRepository(
                innertubeProvider: context.read<InnertubeProvider>())),
        RepositoryProvider<FavoritesRepository>(
            create: (context) => FavoritesRepository())
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider<SearchBloc>(
            create: (context) => SearchBloc(
                innertubeRepository: context.read<InnertubeRepository>())),
        BlocProvider<SearchSuggestionCubit>(
            create: (context) => SearchSuggestionCubit(
                innertubeRepository: context.read<InnertubeRepository>())),
        BlocProvider<SearchSuggestionCubit>(
            create: (context) => SearchSuggestionCubit(
                innertubeRepository: context.read<InnertubeRepository>())),
        BlocProvider<PlayerCubit>(
            create: (context) => PlayerCubit(
                  innertubeRepository: context.read<InnertubeRepository>(),
                  mtPlayerService: context.read<MtPlayerService>(),
                )),
        BlocProvider<FavoritesBloc>(
            create: (context) => FavoritesBloc(
                  favoritesRepository: context.read<FavoritesRepository>(),
                  innertubeRepository: context.read<InnertubeRepository>(),
                ))
      ], child: const MyApp()),
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

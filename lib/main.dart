import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/blocs/update_bloc/update_bloc.dart';
import 'package:my_tube/blocs/theme_cubit/theme_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/models/theme_settings.dart';
import 'package:my_tube/providers/innertube_provider.dart';
import 'package:my_tube/providers/update_provider.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/respositories/favorite_repository.dart';
import 'package:my_tube/respositories/update_repository.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/services/download_service.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:my_tube/services/local_notification_helper.dart.dart';
import 'package:provider/provider.dart';

import 'app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // set edge to edge rendering
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  //Only portrait mode
  //await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Hive.initFlutter();
  Hive.registerAdapter(ResourceMTAdapter());
  await Hive.openBox('settings');
  await Hive.openBox<ResourceMT>('favorites');
  await Hive.openBox<ResourceMT>('channels');
  await Hive.openBox<ResourceMT>('playlists');
  await LocalNotificationHelper.init();

  // Inizializza AudioService con gestione degli errori per Android Auto
  late MtPlayerService mtPlayerService;
  try {
    mtPlayerService = await AudioService.init(
        builder: () => MtPlayerService(),
        config: const AudioServiceConfig(
            androidNotificationChannelId: 'mytube_channel',
            androidNotificationChannelName: 'MyTube',
            androidNotificationOngoing:
                false, // Must be false with androidStopForegroundOnPause: false
            androidStopForegroundOnPause: false, // Importante per Android Auto
            artDownscaleWidth: 256,
            artDownscaleHeight: 256,
            fastForwardInterval: Duration(seconds: 10),
            rewindInterval: Duration(seconds: 10)));

    // Inizializza il rilevamento di Android Auto dopo l'inizializzazione di AudioService
    await mtPlayerService.initializeAndroidAutoDetection();
  } catch (e) {
    log('Errore durante l\'inizializzazione di AudioService: $e');
    // Fallback: crea un'istanza diretta se AudioService non si inizializza
    mtPlayerService = MtPlayerService();
    // Inizializza Android Auto anche nel fallback
    try {
      await mtPlayerService.initializeAndroidAutoDetection();
    } catch (autoError) {
      log('Errore durante l\'inizializzazione di Android Auto nel fallback: $autoError');
    }
  }

  /// Bloc observer
  Bloc.observer = AppBlocObserver();

  runApp(MultiProvider(
    providers: [
      /// Providers and services

      Provider<InnertubeProvider>(create: (context) => InnertubeProvider()),
      Provider<MtPlayerService>(create: (context) => mtPlayerService),
      Provider<DownloadService>(create: (context) => DownloadService()),
      Provider<UpdateProvider>(create: (context) => UpdateProvider()),
    ],
    child: MultiRepositoryProvider(
      /// Repositories
      providers: [
        RepositoryProvider<InnertubeRepository>(
            create: (context) => InnertubeRepository(
                innertubeProvider: context.read<InnertubeProvider>())),
        RepositoryProvider<FavoriteRepository>(
            create: (context) => FavoriteRepository(
                innertubeRepository: context.read<InnertubeRepository>())
              ..migrateData()),
        RepositoryProvider<UpdateRepository>(
            create: (context) => UpdateRepository(
                updateProvider: context.read<UpdateProvider>())),
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()..init()),
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
        BlocProvider<FavoritesVideoBloc>(
            create: (context) => FavoritesVideoBloc(
                  favoritesRepository: context.read<FavoriteRepository>(),
                  innertubeRepository: context.read<InnertubeRepository>(),
                )),
        BlocProvider<FavoritesChannelBloc>(
            create: (context) => FavoritesChannelBloc(
                  favoritesRepository: context.read<FavoriteRepository>(),
                  innertubeRepository: context.read<InnertubeRepository>(),
                )),
        BlocProvider<FavoritesPlaylistBloc>(
            create: (context) => FavoritesPlaylistBloc(
                  favoritesRepository: context.read<FavoriteRepository>(),
                  innertubeRepository: context.read<InnertubeRepository>(),
                )),
        BlocProvider<UpdateBloc>(
            create: (context) =>
                UpdateBloc(updateRepository: context.read<UpdateRepository>())),
      ], child: const MyApp()),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      log('Checking for updates');
      context.read<UpdateBloc>().add(const CheckForUpdate());
    });

    return BlocBuilder<ThemeCubit, ThemeSettings>(
      builder: (context, themeSettings) {
        final themeCubit = context.read<ThemeCubit>();

        return MaterialApp.router(
          title: 'My Tube',
          theme: themeCubit.lightTheme,
          darkTheme: themeCubit.darkTheme,
          themeMode: themeCubit.flutterThemeMode,
          routerConfig: router,
        );
      },
    );
  }
}

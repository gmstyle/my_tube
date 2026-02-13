import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/blocs/update_bloc/update_bloc.dart';
import 'package:my_tube/blocs/theme_cubit/theme_cubit.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/ui/views/common/global_mini_player.dart';
import 'package:my_tube/models/theme_settings.dart';
import 'package:my_tube/providers/youtube_explode_provider.dart';
import 'package:my_tube/providers/update_provider.dart';
import 'package:my_tube/respositories/favorite_repository.dart';
import 'package:my_tube/respositories/update_repository.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/services/download_service.dart';
import 'package:my_tube/services/player/mt_player_service.dart';
import 'package:my_tube/services/local_notification_helper.dart.dart';
import 'package:provider/provider.dart';

import 'app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // set edge to edge rendering
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  //Only portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox<String>('favoriteVideos');
  await Hive.openBox<String>('favoriteChannels');
  await Hive.openBox<String>('favoritePlaylists');
  await LocalNotificationHelper.init();

  // Inizializza provider e repository prima di AudioService
  final YoutubeExplodeProvider youtubeExplodeProvider =
      YoutubeExplodeProvider();
  final YoutubeExplodeRepository youtubeExplodeRepository =
      YoutubeExplodeRepository(
    youtubeExplodeProvider: youtubeExplodeProvider,
  );
  final FavoriteRepository favoriteRepository = FavoriteRepository(
    youtubeExplodeRepository: youtubeExplodeRepository,
  );

  // Inizializza AudioService con gestione degli errori per Android Auto
  late MtPlayerService mtPlayerService;
  try {
    mtPlayerService = await AudioService.init(
        builder: () => MtPlayerService(
              youtubeExplodeProvider: youtubeExplodeProvider,
              favoriteRepository: favoriteRepository,
              youtubeExplodeRepository: youtubeExplodeRepository,
            ),
        config: const AudioServiceConfig(
            androidNotificationChannelId: 'mytube_channel',
            androidNotificationChannelName: 'MyTube',
            androidNotificationOngoing:
                false, // Must be false with androidStopForegroundOnPause: false
            androidStopForegroundOnPause: false, // Importante per Android Auto
            artDownscaleWidth: 256,
            artDownscaleHeight: 256,
            androidBrowsableRootExtras: {
              'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT':
                  2, // 2 = Grid, 1 = List
              'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT': 2,
              'android.media.browse.SEARCH_SUPPORTED': true,
            },
            fastForwardInterval: Duration(seconds: 10),
            rewindInterval: Duration(seconds: 10)));
  } catch (e) {
    log('Errore durante l\'inizializzazione di AudioService: $e');
    // Fallback: crea un'istanza diretta se AudioService non si inizializza
    mtPlayerService = MtPlayerService(
      youtubeExplodeProvider: youtubeExplodeProvider,
      favoriteRepository: favoriteRepository,
      youtubeExplodeRepository: youtubeExplodeRepository,
    );
  }

  /// Bloc observer
  Bloc.observer = AppBlocObserver();

  runApp(MultiProvider(
    providers: [
      /// Providers and services

      /// Provider YouTube Explode - Nuovo provider basato su youtube_explode_dart
      Provider<YoutubeExplodeProvider>.value(value: youtubeExplodeProvider),

      Provider<MtPlayerService>.value(value: mtPlayerService),
      Provider<DownloadService>(create: (context) => DownloadService()),
      Provider<UpdateProvider>(create: (context) => UpdateProvider()),
    ],
    child: MultiRepositoryProvider(
      /// Repositories
      providers: [
        // Usa le istanze già create per Android Auto
        RepositoryProvider<YoutubeExplodeRepository>.value(
            value: youtubeExplodeRepository),
        RepositoryProvider<FavoriteRepository>.value(value: favoriteRepository),
        RepositoryProvider<UpdateRepository>(
            create: (context) => UpdateRepository(
                updateProvider: context.read<UpdateProvider>())),
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()..init()),
        BlocProvider<SearchBloc>(
            create: (context) => SearchBloc(
                youtubeExplodeRepository:
                    context.read<YoutubeExplodeRepository>())),
        BlocProvider<SearchSuggestionCubit>(
            create: (context) => SearchSuggestionCubit(
                youtubeExplodeRepository:
                    context.read<YoutubeExplodeRepository>())),
        BlocProvider<PlayerCubit>(
            create: (context) => PlayerCubit(
                  youtubeExplodeRepository:
                      context.read<YoutubeExplodeRepository>(),
                  mtPlayerService: context.read<MtPlayerService>(),
                )..init()),
        BlocProvider<FavoritesVideoBloc>(
            create: (context) => FavoritesVideoBloc(
                  favoritesRepository: context.read<FavoriteRepository>(),
                )),
        BlocProvider<FavoritesChannelBloc>(
            create: (context) => FavoritesChannelBloc(
                  favoritesRepository: context.read<FavoriteRepository>(),
                )),
        BlocProvider<FavoritesPlaylistBloc>(
            create: (context) => FavoritesPlaylistBloc(
                  favoritesRepository: context.read<FavoriteRepository>(),
                )),
        BlocProvider<UpdateBloc>(
            create: (context) =>
                UpdateBloc(updateRepository: context.read<UpdateRepository>())),
        BlocProvider<PersistentUiCubit>(
            create: (context) => PersistentUiCubit()),
      ], child: const MyApp()),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router;

    if (!kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        log('Checking for updates');
        context.read<UpdateBloc>().add(const CheckForUpdate());
      });
    }

    return BlocBuilder<ThemeCubit, ThemeSettings>(
      builder: (context, themeSettings) {
        final themeCubit = context.read<ThemeCubit>();

        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            return MaterialApp.router(
              title: 'My Tube',
              theme: themeCubit.lightTheme(lightDynamic),
              darkTheme: themeCubit.darkTheme(darkDynamic),
              themeMode: themeCubit.flutterThemeMode,
              routerConfig: router,
              builder: (context, child) {
                return Stack(
                  children: [
                    if (child != null) child,
                    Overlay(
                      initialEntries: [
                        OverlayEntry(
                          builder: (context) => const GlobalMiniPlayer(),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

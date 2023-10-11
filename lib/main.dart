import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/providers/auth_provider.dart';
import 'package:my_tube/providers/youtube_provider.dart';
import 'package:my_tube/respositories/auth_repository.dart';
import 'package:my_tube/respositories/mappers/search_mapper.dart';
import 'package:my_tube/respositories/mappers/video_mapper.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:provider/provider.dart';

import 'app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');

  /// Bloc observer
  Bloc.observer = AppBlocObserver();

  runApp(MultiProvider(
    providers: [
      /// Providers
      Provider<AuthProvider>(create: (context) => AuthProvider()),
      Provider(create: (context) => YoutubeProvider()),
    ],
    child: MultiProvider(
      providers: [
        /// Mappers
        Provider<VideoMapper>(create: (context) => VideoMapper()),
        Provider<SearchMapper>(create: (context) => SearchMapper()),
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
                searchMapper: context.read<SearchMapper>()),
          ),
        ],
        child: const MyApp(),
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

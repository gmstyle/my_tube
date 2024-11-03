import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/settings/cubit/settings_cubit.dart';
import 'package:my_tube/ui/views/settings/settings_view.dart';

class SettingsPage extends Page {
  const SettingsPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => SettingsCubit(),
          child: const SettingsView(),
        );
      },
    );
  }
}

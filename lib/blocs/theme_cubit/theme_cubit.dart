import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_tube/models/theme_settings.dart';

class ThemeCubit extends Cubit<ThemeSettings> {
  ThemeCubit() : super(const ThemeSettings());

  final Box settingsBox = Hive.box('settings');

  void init() {
    final themeSettingsJson = settingsBox.get('themeSettings');
    if (themeSettingsJson != null) {
      final themeSettings =
          ThemeSettings.fromJson(Map<String, dynamic>.from(themeSettingsJson));
      emit(themeSettings);
    }
  }

  void updateThemeMode(ThemeMode themeMode) {
    final newSettings = state.copyWith(themeMode: themeMode);
    settingsBox.put('themeSettings', newSettings.toJson());
    emit(newSettings);
  }

  void updatePrimaryColor(flutter_material.Color color) {
    final newSettings = state.copyWith(primaryColor: color);
    settingsBox.put('themeSettings', newSettings.toJson());
    emit(newSettings);
  }

  void updateGradientEnabled(bool enabled) {
    final newSettings = state.copyWith(enableGradient: enabled);
    settingsBox.put('themeSettings', newSettings.toJson());
    emit(newSettings);
  }

  // Convert our custom ThemeMode to Flutter's ThemeMode
  flutter_material.ThemeMode get flutterThemeMode {
    switch (state.themeMode) {
      case ThemeMode.light:
        return flutter_material.ThemeMode.light;
      case ThemeMode.dark:
        return flutter_material.ThemeMode.dark;
      case ThemeMode.system:
        return flutter_material.ThemeMode.system;
    }
  }

  flutter_material.ThemeData get lightTheme {
    return flutter_material.ThemeData(
      colorScheme: flutter_material.ColorScheme.fromSeed(
        seedColor: state.primaryColor,
        brightness: flutter_material.Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: flutter_material.Colors.transparent,
      appBarTheme: const flutter_material.AppBarTheme(
        backgroundColor: flutter_material.Colors.transparent,
        elevation: 0,
      ),
    );
  }

  flutter_material.ThemeData get darkTheme {
    return flutter_material.ThemeData(
      colorScheme: flutter_material.ColorScheme.fromSeed(
        seedColor: state.primaryColor,
        brightness: flutter_material.Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: flutter_material.Colors.transparent,
      appBarTheme: const flutter_material.AppBarTheme(
        backgroundColor: flutter_material.Colors.transparent,
        elevation: 0,
      ),
    );
  }
}

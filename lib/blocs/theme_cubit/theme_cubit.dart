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
    final cs = flutter_material.ColorScheme.fromSeed(
      seedColor: state.primaryColor,
      brightness: flutter_material.Brightness.light,
    );

    return flutter_material.ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: flutter_material.AppBarTheme(
        backgroundColor: cs.surface,
        elevation: 0,
        foregroundColor: cs.onSurface,
      ),
      tabBarTheme: flutter_material.TabBarThemeData(
        labelColor: cs.onPrimary,
        unselectedLabelColor: cs.onSurface.withValues(alpha: 0.7),
        indicator: flutter_material.UnderlineTabIndicator(
          borderSide: flutter_material.BorderSide(color: cs.primary, width: 3),
        ),
        indicatorSize: flutter_material.TabBarIndicatorSize.label,
        labelStyle: flutter_material.TextStyle(
            fontWeight: flutter_material.FontWeight.w600),
      ),
    );
  }

  flutter_material.ThemeData get darkTheme {
    final cs = flutter_material.ColorScheme.fromSeed(
      seedColor: state.primaryColor,
      brightness: flutter_material.Brightness.dark,
    );

    return flutter_material.ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: flutter_material.AppBarTheme(
        backgroundColor: cs.surface,
        elevation: 0,
        foregroundColor: cs.onSurface,
      ),
      tabBarTheme: flutter_material.TabBarThemeData(
        labelColor: cs.onPrimary,
        unselectedLabelColor: cs.onSurface.withValues(alpha: 0.7),
        indicator: flutter_material.UnderlineTabIndicator(
          borderSide: flutter_material.BorderSide(color: cs.primary, width: 3),
        ),
        indicatorSize: flutter_material.TabBarIndicatorSize.label,
        labelStyle: flutter_material.TextStyle(
            fontWeight: flutter_material.FontWeight.w600),
      ),
    );
  }
}

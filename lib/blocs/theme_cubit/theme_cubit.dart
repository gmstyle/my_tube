import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter/services.dart';
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

  void updateUseDynamicColor(bool enabled) {
    final newSettings = state.copyWith(useDynamicColor: enabled);
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

  flutter_material.ThemeData lightTheme(
      flutter_material.ColorScheme? dynamicColorScheme) {
    final cs = (state.useDynamicColor && dynamicColorScheme != null)
        ? dynamicColorScheme
        : flutter_material.ColorScheme.fromSeed(
            seedColor: flutter_material.Colors.deepPurple,
            brightness: flutter_material.Brightness.light,
          );

    return flutter_material.ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: flutter_material.AppBarTheme(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        foregroundColor: cs.onSurface,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: flutter_material.Colors.transparent,
          statusBarIconBrightness: flutter_material.Brightness.dark,
          statusBarBrightness: flutter_material.Brightness.light,
          systemNavigationBarColor: cs.surface,
          systemNavigationBarIconBrightness: flutter_material.Brightness.dark,
        ),
      ),
      navigationBarTheme: flutter_material.NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.secondaryContainer,
        labelTextStyle:
            flutter_material.WidgetStateProperty.resolveWith((states) {
          if (states.contains(flutter_material.WidgetState.selected)) {
            return flutter_material.TextStyle(
                color: cs.onSurface,
                fontWeight: flutter_material.FontWeight.bold);
          }
          return flutter_material.TextStyle(color: cs.onSurfaceVariant);
        }),
      ),
      tabBarTheme: flutter_material.TabBarThemeData(
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: cs.primary,
        indicatorSize: flutter_material.TabBarIndicatorSize.label,
        labelStyle: flutter_material.TextStyle(
            fontWeight: flutter_material.FontWeight.w600),
      ),
    );
  }

  flutter_material.ThemeData darkTheme(
      flutter_material.ColorScheme? dynamicColorScheme) {
    final cs = (state.useDynamicColor && dynamicColorScheme != null)
        ? dynamicColorScheme
        : flutter_material.ColorScheme.fromSeed(
            seedColor: flutter_material.Colors.deepPurple,
            brightness: flutter_material.Brightness.dark,
          );

    return flutter_material.ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: flutter_material.AppBarTheme(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        foregroundColor: cs.onSurface,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: flutter_material.Colors.transparent,
          statusBarIconBrightness: flutter_material.Brightness.light,
          statusBarBrightness: flutter_material.Brightness.dark,
          systemNavigationBarColor: cs.surface,
          systemNavigationBarIconBrightness: flutter_material.Brightness.light,
        ),
      ),
      navigationBarTheme: flutter_material.NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.secondaryContainer,
        labelTextStyle:
            flutter_material.WidgetStateProperty.resolveWith((states) {
          if (states.contains(flutter_material.WidgetState.selected)) {
            return flutter_material.TextStyle(
                color: cs.onSurface,
                fontWeight: flutter_material.FontWeight.bold);
          }
          return flutter_material.TextStyle(color: cs.onSurfaceVariant);
        }),
      ),
      tabBarTheme: flutter_material.TabBarThemeData(
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: cs.primary,
        indicatorSize: flutter_material.TabBarIndicatorSize.label,
        labelStyle: flutter_material.TextStyle(
            fontWeight: flutter_material.FontWeight.w600),
      ),
    );
  }
}

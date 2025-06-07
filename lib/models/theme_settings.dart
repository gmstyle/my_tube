import 'package:flutter/material.dart' as flutter_material;

enum ThemeMode { light, dark, system }

class ThemeSettings {
  final ThemeMode themeMode;
  final flutter_material.Color primaryColor;
  final bool enableGradient;

  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.primaryColor = flutter_material.Colors.deepPurple,
    this.enableGradient = true,
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    flutter_material.Color? primaryColor,
    bool? enableGradient,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      enableGradient: enableGradient ?? this.enableGradient,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'primaryColor': primaryColor.toARGB32(),
      'enableGradient': enableGradient,
    };
  }

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 2],
      primaryColor: flutter_material.Color(json['primaryColor'] ??
          flutter_material.Colors.deepPurple.toARGB32()),
      enableGradient: json['enableGradient'] ?? true,
    );
  }

  static const List<flutter_material.Color> predefinedColors = [
    // Colori Material Design vivaci e accessibili
    flutter_material.Colors.deepPurple, // Viola profondo (default)
    flutter_material.Colors.blue, // Blu
    flutter_material.Colors.red, // Rosso
    flutter_material.Colors.green, // Verde
    flutter_material.Colors.orange, // Arancione
    flutter_material.Colors.pink, // Rosa
    flutter_material.Colors.teal, // Verde acqua
    flutter_material.Colors.indigo, // Indaco
    flutter_material.Colors.cyan, // Ciano
    flutter_material.Colors.amber, // Ambra
    flutter_material.Colors.deepOrange, // Arancione scuro
    flutter_material.Colors.purple, // Viola
  ];

  static String getThemeModeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

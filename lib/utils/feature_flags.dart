/// Feature flags per controllare l'abilitazione di nuove funzionalità
class FeatureFlags {
  /// Usa youtube_explode_dart invece di innertube_dart
  static const bool useYoutubeExplode = bool.fromEnvironment(
    'USE_YOUTUBE_EXPLODE',
    defaultValue: true, // Per ora abilitiamo il nuovo provider di default
  );

  /// Flag per debug e logging
  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: false,
  );
}

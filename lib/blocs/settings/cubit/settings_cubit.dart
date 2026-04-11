import 'package:bloc/bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_tube/models/theme_settings.dart';
import 'package:my_tube/utils/constants.dart';

class SettingsState {
  final String country;
  final ThemeSettings themeSettings;
  final bool getRelatedVideos;

  const SettingsState({
    required this.country,
    required this.themeSettings,
    required this.getRelatedVideos,
  });

  SettingsState copyWith({
    String? country,
    ThemeSettings? themeSettings,
    bool? getRelatedVideos,
  }) {
    return SettingsState(
      country: country ?? this.country,
      themeSettings: themeSettings ?? this.themeSettings,
      getRelatedVideos: getRelatedVideos ?? this.getRelatedVideos,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(const SettingsState(
          country: defaultCountryCode,
          themeSettings: ThemeSettings(),
          getRelatedVideos: true,
        ));

  final settingsBox = Hive.box(hiveSettingsBoxName);

  void init() {
    final countryCode = settingsBox.get(settingsCountryCodeKey,
        defaultValue: defaultCountryCode);
    final themeSettingsJson = settingsBox.get(settingsThemeSettingsKey);

    final themeSettings = themeSettingsJson != null
        ? ThemeSettings.fromJson(Map<String, dynamic>.from(themeSettingsJson))
        : const ThemeSettings();

    final getRelatedVideos =
        settingsBox.get(settingsGetRelatedVideosKey, defaultValue: true);

    emit(SettingsState(
      country: countryCode,
      themeSettings: themeSettings,
      getRelatedVideos: getRelatedVideos,
    ));
  }

  void setCountry(String countryCode) {
    settingsBox.put(settingsCountryCodeKey, countryCode);
    emit(state.copyWith(country: countryCode));
  }

  void setThemeMode(ThemeMode themeMode) {
    final newThemeSettings = state.themeSettings.copyWith(themeMode: themeMode);
    settingsBox.put(settingsThemeSettingsKey, newThemeSettings.toJson());
    emit(state.copyWith(themeSettings: newThemeSettings));
  }

  void setUseDynamicColor(bool enabled) {
    final newThemeSettings =
        state.themeSettings.copyWith(useDynamicColor: enabled);
    settingsBox.put(settingsThemeSettingsKey, newThemeSettings.toJson());
    emit(state.copyWith(themeSettings: newThemeSettings));
  }

  void setGetRelatedVideos(bool enabled) {
    settingsBox.put(settingsGetRelatedVideosKey, enabled);
    emit(state.copyWith(getRelatedVideos: enabled));
  }
}

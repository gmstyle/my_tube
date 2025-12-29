import 'package:bloc/bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_tube/models/theme_settings.dart';

class SettingsState {
  final String country;
  final ThemeSettings themeSettings;

  const SettingsState({
    required this.country,
    required this.themeSettings,
  });

  SettingsState copyWith({
    String? country,
    ThemeSettings? themeSettings,
  }) {
    return SettingsState(
      country: country ?? this.country,
      themeSettings: themeSettings ?? this.themeSettings,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(const SettingsState(
          country: 'US',
          themeSettings: ThemeSettings(),
        ));

  final settingsBox = Hive.box('settings');

  void init() {
    final countryCode = settingsBox.get('countryCode', defaultValue: 'US');
    final themeSettingsJson = settingsBox.get('themeSettings');

    final themeSettings = themeSettingsJson != null
        ? ThemeSettings.fromJson(Map<String, dynamic>.from(themeSettingsJson))
        : const ThemeSettings();

    emit(SettingsState(
      country: countryCode,
      themeSettings: themeSettings,
    ));
  }

  void setCountry(String countryCode) {
    settingsBox.put('countryCode', countryCode);
    emit(state.copyWith(country: countryCode));
  }

  void setThemeMode(ThemeMode themeMode) {
    final newThemeSettings = state.themeSettings.copyWith(themeMode: themeMode);
    settingsBox.put('themeSettings', newThemeSettings.toJson());
    emit(state.copyWith(themeSettings: newThemeSettings));
  }

  void setUseDynamicColor(bool enabled) {
    final newThemeSettings =
        state.themeSettings.copyWith(useDynamicColor: enabled);
    settingsBox.put('themeSettings', newThemeSettings.toJson());
    emit(state.copyWith(themeSettings: newThemeSettings));
  }
}

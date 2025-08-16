import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/settings/cubit/settings_cubit.dart';
import 'package:my_tube/blocs/theme_cubit/theme_cubit.dart';
import 'package:my_tube/models/theme_settings.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/settings/widgets/color_selection_dialog.dart';
import 'package:my_tube/utils/constants.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>()..init();
    final themeCubit = context.read<ThemeCubit>();

    return MainGradient(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppbar(
            title: Text('Settings',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          ),
          body: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return BlocBuilder<ThemeCubit, ThemeSettings>(
                builder: (context, themeSettings) {
                  return ListView(
                    children: [
                      // Theme & Appearance Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Theme & Appearance',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),

                      // YouTube Explode Test
                      ListTile(
                        leading: Icon(Icons.science,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text('Test YouTube Explode',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        subtitle: Text(
                            'Test del nuovo provider YouTube Explode',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withValues(alpha: 0.6))),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.onPrimary),
                        onTap: () => context.pushNamed('testYoutubeExplode'),
                      ),

                      // Theme Mode Setting
                      ListTile(
                        leading: Icon(Icons.dark_mode,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text('Theme Mode',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        subtitle: Text(
                            'Choose between light, dark, or system theme',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withValues(alpha: 0.6))),
                        trailing: Text(
                            ThemeSettings.getThemeModeDisplayName(
                                themeSettings.themeMode),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        onTap: () => _showThemeModeDialog(
                            context, themeCubit, themeSettings.themeMode),
                      ),

                      // Primary Color Setting
                      ListTile(
                        leading: Icon(Icons.palette,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text('Primary Color',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        subtitle: Text('Customize the app\'s primary color',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withValues(alpha: 0.6))),
                        trailing: ColorPreview(
                          color: themeSettings.primaryColor,
                          onTap: () => _showColorSelectionDialog(
                              context, themeCubit, themeSettings.primaryColor),
                        ),
                        onTap: () => _showColorSelectionDialog(
                            context, themeCubit, themeSettings.primaryColor),
                      ),

                      // Gradient Setting
                      SwitchListTile(
                        secondary: Icon(Icons.gradient,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text('Enable Gradient Background',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        subtitle: Text(
                            'Use gradient background throughout the app',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withValues(alpha: 0.6))),
                        value: themeSettings.enableGradient,
                        onChanged: (value) =>
                            themeCubit.updateGradientEnabled(value),
                        activeThumbColor: Colors.white,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveThumbColor: Colors.grey[400],
                        inactiveTrackColor: Colors.grey[700],
                      ),

                      const Divider(height: 32),

                      // General Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'General',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),

                      // Country Setting
                      ListTile(
                        leading: Icon(Icons.language,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text('Country',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        subtitle: Text(
                            'Default is based on your IP address, but you can change it',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withValues(alpha: 0.6))),
                        trailing: Text(state.country,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        onTap: () async {
                          // show a bottom sheet with a list of countries to choose from
                          final selectedCountry =
                              await showModalBottomSheet<String>(
                            context: context,
                            builder: (context) {
                              return ListView.builder(
                                itemCount: countryToLanguage.keys.length,
                                itemBuilder: (context, index) {
                                  final country =
                                      countryToLanguage.keys.elementAt(index);

                                  return ListTile(
                                    title: Text(country),
                                    onTap: () => context.pop(country),
                                  );
                                },
                              );
                            },
                          );
                          if (selectedCountry != null) {
                            settingsCubit.setCountry(selectedCountry);
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          )),
    );
  }

  void _showThemeModeDialog(
      BuildContext context, ThemeCubit themeCubit, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(ThemeSettings.getThemeModeDisplayName(mode)),
              value: mode,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  themeCubit.updateThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showColorSelectionDialog(BuildContext context, ThemeCubit themeCubit,
      flutter_material.Color currentColor) {
    showDialog(
      context: context,
      builder: (context) => ColorSelectionDialog(
        currentColor: currentColor,
        onColorSelected: (color) {
          themeCubit.updatePrimaryColor(color);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

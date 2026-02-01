import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/settings/cubit/settings_cubit.dart';
import 'package:my_tube/blocs/theme_cubit/theme_cubit.dart';
import 'package:my_tube/models/theme_settings.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/blocs/update_bloc/update_bloc.dart';
import 'package:my_tube/utils/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>()..init();
    final themeCubit = context.read<ThemeCubit>();

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final packageInfo = snapshot.data;
        final version = packageInfo != null
            ? '${packageInfo.version}+${packageInfo.buildNumber}'
            : '...';

        return Scaffold(
            appBar: const CustomAppbar(
              title: Text('Settings'),
            ),
            body: MultiBlocListener(
              listeners: [
                BlocListener<UpdateBloc, UpdateState>(
                  listener: (context, state) {
                    if (state.status == UpdateStatus.noUpdateAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You are on the latest version'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else if (state.status == UpdateStatus.failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Failed to check for updates: ${state.errorMessage}'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                ),
              ],
              child: BlocBuilder<SettingsCubit, SettingsState>(
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
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),

                          // Theme Mode Setting
                          ListTile(
                            leading: const Icon(Icons.dark_mode),
                            title: const Text('Theme Mode'),
                            subtitle: Text(
                                'Choose between light, dark, or system theme',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                            trailing: Text(
                                ThemeSettings.getThemeModeDisplayName(
                                    themeSettings.themeMode)),
                            onTap: () => _showThemeModeDialog(
                                context, themeCubit, themeSettings.themeMode),
                          ),

                          // Dynamic Color Setting
                          SwitchListTile(
                            secondary: const Icon(Icons.palette),
                            title: const Text('Dynamic Color'),
                            subtitle: Text('Use system colors (Material You)',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                            value: themeSettings.useDynamicColor,
                            onChanged: (value) =>
                                themeCubit.updateUseDynamicColor(value),
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
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),

                          // Country Setting
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: const Text('Country'),
                            subtitle: Text(
                                'Default is based on your IP address, but you can change it',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                            trailing: Text(state.country),
                            onTap: () async {
                              // show a bottom sheet with a list of countries to choose from
                              final selectedCountry =
                                  await showModalBottomSheet<String>(
                                context: context,
                                builder: (context) {
                                  return ListView.builder(
                                    itemCount: countryToLanguage.keys.length,
                                    itemBuilder: (context, index) {
                                      final country = countryToLanguage.keys
                                          .elementAt(index);

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

                          const Divider(height: 32),

                          // About Section
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'About',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),

                          // App Version
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('App Version'),
                            subtitle: Text(version,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          ),

                          // Check for Updates
                          BlocBuilder<UpdateBloc, UpdateState>(
                            builder: (context, updateState) {
                              final isChecking =
                                  updateState.status == UpdateStatus.checking;
                              return ListTile(
                                leading: isChecking
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.update),
                                title: const Text('Check for Updates'),
                                subtitle: Text(
                                    isChecking
                                        ? 'Checking...'
                                        : 'Check if a newer version is available',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                                onTap: isChecking
                                    ? null
                                    : () {
                                        context
                                            .read<UpdateBloc>()
                                            .add(const CheckForUpdate());
                                      },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ));
      },
    );
  }

  void _showThemeModeDialog(
      BuildContext context, ThemeCubit themeCubit, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme Mode'),
        content: RadioGroup<ThemeMode>(
          groupValue: currentMode,
          onChanged: (value) {
            if (value != null) {
              themeCubit.updateThemeMode(value);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((mode) {
              return RadioListTile<ThemeMode>(
                title: Text(ThemeSettings.getThemeModeDisplayName(mode)),
                value: mode,
              );
            }).toList(),
          ),
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
}

import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/blocs/settings/cubit/settings_cubit.dart';
import 'package:my_tube/blocs/theme_cubit/theme_cubit.dart';
import 'package:my_tube/blocs/backup_restore/backup_restore_cubit.dart';
import 'package:my_tube/blocs/backup_restore/backup_restore_state.dart';
import 'package:my_tube/models/theme_settings.dart';
import 'package:my_tube/blocs/update_bloc/update_bloc.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';
import 'package:my_tube/utils/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SettingsView
// ─────────────────────────────────────────────────────────────────────────────

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      context.read<PersistentUiCubit>().setNavBarVisibility(true);
    }
    final settingsCubit = context.read<SettingsCubit>()..init();
    final themeCubit = context.read<ThemeCubit>();

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final packageInfo = snapshot.data;
        final version = packageInfo != null ? packageInfo.version : '...';

        return MultiBlocListener(
          listeners: [
            BlocListener<UpdateBloc, UpdateState>(
              listener: (context, state) {
                if (state.status == UpdateStatus.noUpdateAvailable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(settingsLatestVersionMessage),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else if (state.status == UpdateStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '$settingsUpdateCheckFailurePrefix${state.errorMessage}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
            ),
            BlocListener<BackupRestoreCubit, BackupRestoreState>(
              listener: (context, state) {
                if (state.status == BackupRestoreStatus.success && state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage!),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else if (state.status == BackupRestoreStatus.failure && state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      duration: const Duration(seconds: 4),
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
                  final theme = Theme.of(context);
                  final cs = theme.colorScheme;

                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        // ── App banner ────────────────────────────────────────
                        _AppBanner(version: version),
                        const SizedBox(height: 16),

                        // ── Theme & Appearance ────────────────────────────────
                        _SettingsCard(
                          label: settingsThemeAppearanceLabel,
                          icon: Icons.palette_outlined,
                          iconColor: cs.primaryContainer,
                          iconOnColor: cs.onPrimaryContainer,
                          children: [
                            // Theme mode header row
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Row(
                                children: [
                                  _IconContainer(
                                    icon: Icons.dark_mode_outlined,
                                    color: cs.primaryContainer,
                                    onColor: cs.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(settingsThemeModeTitle,
                                            style: theme.textTheme.bodyLarge),
                                        Text(
                                          settingsThemeModeSubtitle,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: cs.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Inline SegmentedButton — no dialog needed
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                              child: SegmentedButton<ThemeMode>(
                                selected: {themeSettings.themeMode},
                                onSelectionChanged: (val) =>
                                    themeCubit.updateThemeMode(val.first),
                                showSelectedIcon: false,
                                style: SegmentedButton.styleFrom(
                                  selectedBackgroundColor: cs.primaryContainer,
                                  selectedForegroundColor:
                                      cs.onPrimaryContainer,
                                ),
                                segments: const [
                                  ButtonSegment(
                                    value: ThemeMode.light,
                                    icon: Icon(Icons.light_mode_outlined,
                                        size: 18),
                                    label: Text(settingsThemeLightLabel),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.dark,
                                    icon: Icon(Icons.dark_mode_outlined,
                                        size: 18),
                                    label: Text(settingsThemeDarkLabel),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.system,
                                    icon: Icon(Icons.phone_android_outlined,
                                        size: 18),
                                    label: Text(settingsThemeSystemLabel),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: cs.outline.withValues(alpha: 0.15),
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                            // Dynamic Color
                            SwitchListTile(
                              secondary: _IconContainer(
                                icon: Icons.auto_awesome_outlined,
                                color: cs.tertiaryContainer,
                                onColor: cs.onTertiaryContainer,
                              ),
                              title: const Text(settingsDynamicColorTitle),
                              subtitle: Text(
                                settingsDynamicColorSubtitle,
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                              value: themeSettings.useDynamicColor,
                              onChanged: (value) =>
                                  themeCubit.updateUseDynamicColor(value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ── General ───────────────────────────────────────────
                        _SettingsCard(
                          label: settingsGeneralLabel,
                          icon: Icons.tune_outlined,
                          iconColor: cs.secondaryContainer,
                          iconOnColor: cs.onSecondaryContainer,
                          children: [
                            ListTile(
                              leading: _IconContainer(
                                icon: Icons.language_outlined,
                                color: cs.secondaryContainer,
                                onColor: cs.onSecondaryContainer,
                              ),
                              title: const Text(settingsCountryTitle),
                              subtitle: Text(
                                settingsCountrySubtitle,
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                              trailing: Chip(
                                label: Text(
                                  state.country,
                                  style: theme.textTheme.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                backgroundColor: cs.secondaryContainer,
                                side: BorderSide.none,
                              ),
                              onTap: () async {
                                final selectedCountry =
                                    await showModalBottomSheet<String>(
                                  context: context,
                                  isScrollControlled: true,
                                  useRootNavigator: true,
                                  builder: (context) => _CountryPickerSheet(
                                      selected: state.country),
                                );
                                if (selectedCountry != null) {
                                  settingsCubit.setCountry(selectedCountry);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ── Data & Backup ───────────────────────────────────────
                        _SettingsCard(
                          label: 'Data & Backup',
                          icon: Icons.save_outlined,
                          iconColor: cs.tertiaryContainer,
                          iconOnColor: cs.onTertiaryContainer,
                          children: [
                            BlocBuilder<BackupRestoreCubit, BackupRestoreState>(
                              builder: (context, backupState) {
                                final isLoading = backupState.status == BackupRestoreStatus.loading;
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: _IconContainer(
                                        icon: Icons.upload_file_outlined,
                                        color: cs.tertiaryContainer,
                                        onColor: cs.onTertiaryContainer,
                                      ),
                                      title: const Text('Export Data'),
                                      subtitle: Text(
                                        'Save settings, favorites and playlists',
                                        style: TextStyle(color: cs.onSurfaceVariant),
                                      ),
                                      trailing: isLoading 
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                                          : const Icon(Icons.chevron_right),
                                      onTap: isLoading ? null : () => context.read<BackupRestoreCubit>().exportData(),
                                    ),
                                    Divider(
                                      color: cs.outline.withValues(alpha: 0.15),
                                      height: 1,
                                      indent: 64,
                                      endIndent: 16,
                                    ),
                                    ListTile(
                                      leading: _IconContainer(
                                        icon: Icons.file_download_outlined,
                                        color: cs.tertiaryContainer,
                                        onColor: cs.onTertiaryContainer,
                                      ),
                                      title: const Text('Import Data'),
                                      subtitle: Text(
                                        'Restore from a previous backup',
                                        style: TextStyle(color: cs.onSurfaceVariant),
                                      ),
                                      trailing: isLoading 
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                                          : const Icon(Icons.chevron_right),
                                      onTap: isLoading ? null : () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Restore Data'),
                                            content: const Text('Importing data will overwrite your current settings, favorites, and playlists. Are you sure you want to proceed?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text(actionCancelLabel),
                                              ),
                                              FilledButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text('Restore'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true && context.mounted) {
                                          context.read<BackupRestoreCubit>().importData();
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ── About ─────────────────────────────────────────────
                        _SettingsCard(
                          label: settingsAboutLabel,
                          icon: Icons.info_outline,
                          iconColor: cs.surfaceContainerHighest,
                          iconOnColor: cs.onSurfaceVariant,
                          children: [
                            BlocBuilder<UpdateBloc, UpdateState>(
                              builder: (context, updateState) {
                                final isChecking =
                                    updateState.status == UpdateStatus.checking;
                                return ListTile(
                                  leading: _IconContainer(
                                    icon: Icons.update_outlined,
                                    color: cs.surfaceContainerHighest,
                                    onColor: cs.onSurfaceVariant,
                                  ),
                                  title: const Text(settingsCheckUpdatesTitle),
                                  subtitle: Text(
                                    isChecking
                                        ? settingsCheckingSubtitle
                                        : settingsCheckUpdatesSubtitle,
                                    style:
                                        TextStyle(color: cs.onSurfaceVariant),
                                  ),
                                  trailing: FilledButton.tonal(
                                    onPressed: isChecking
                                        ? null
                                        : () => context
                                            .read<UpdateBloc>()
                                            .add(const CheckForUpdate()),
                                    child: isChecking
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Text(actionCheckLabel),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AppBanner
// ─────────────────────────────────────────────────────────────────────────────

class _AppBanner extends StatelessWidget {
  const _AppBanner({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primaryContainer.withValues(alpha: 0.65),
              cs.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MyTube',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Version $version',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingsCard — card container for a settings section
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconOnColor,
    required this.children,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconOnColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: cs.outline.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section label inside the card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 15, color: iconOnColor),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _IconContainer — colored rounded icon for ListTile leading
// ─────────────────────────────────────────────────────────────────────────────

class _IconContainer extends StatelessWidget {
  const _IconContainer({
    required this.icon,
    required this.color,
    required this.onColor,
  });

  final IconData icon;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: onColor),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CountryPickerSheet — DraggableScrollableSheet with live search
// ─────────────────────────────────────────────────────────────────────────────

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.selected});

  final String selected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late final TextEditingController _searchController;
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = countryToLanguage.keys.toList();
    _searchController = TextEditingController()
      ..addListener(() {
        final query = _searchController.text.toLowerCase();
        setState(() {
          _filtered = countryToLanguage.keys
              .where((c) => c.toLowerCase().contains(query))
              .toList();
        });
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  settingsSelectCountryTitle,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: theme.enhancedInputDecoration.copyWith(
                  hintText: settingsSearchCountryHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Country list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final country = _filtered[index];
                  final isSelected = country == widget.selected;
                  return ListTile(
                    title: Text(country),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: cs.primary)
                        : null,
                    selected: isSelected,
                    selectedTileColor:
                        cs.primaryContainer.withValues(alpha: 0.3),
                    onTap: () => Navigator.of(context).pop(country),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

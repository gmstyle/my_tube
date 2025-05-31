import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/settings/cubit/settings_cubit.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/utils/constants.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>()..init();

    return MainGradient(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppbar(
            title: Text('Settings',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          ),
          body: BlocBuilder<SettingsCubit, dynamic>(
            builder: (context, state) {
              final country = state as String;

              return ListView(
                children: [
                  // show locale settings
                  ListTile(
                    title: Text('Country',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary)),
                    subtitle: Text(
                        'Default is based on your IP address, but you can change it',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondary
                                .withValues(alpha: 0.6))),
                    trailing: Text(country,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary)),
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
          )),
    );
  }
}

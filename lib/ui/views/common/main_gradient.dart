import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/theme_cubit/theme_cubit.dart';
import 'package:my_tube/models/theme_settings.dart';

class MainGradient extends StatelessWidget {
  const MainGradient({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeSettings>(
      builder: (context, themeSettings) {
        if (!themeSettings.enableGradient) {
          // Usa il colore primario selezionato a tinta unita
          return Container(
            decoration: BoxDecoration(
              color: themeSettings.primaryColor,
            ),
            child: child,
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

import 'package:flutter/material.dart' as flutter_material;
import 'package:my_tube/models/theme_settings.dart';

class ColorSelectionDialog extends flutter_material.StatelessWidget {
  final flutter_material.Color currentColor;
  final Function(flutter_material.Color) onColorSelected;

  const ColorSelectionDialog({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  flutter_material.Widget build(flutter_material.BuildContext context) {
    return flutter_material.AlertDialog(
      title: const flutter_material.Text('Select Theme Color'),
      content: flutter_material.SizedBox(
        width: double.maxFinite,
        height: 240, // Altezza fissa per gestire 3 righe di 4 colori
        child: flutter_material.GridView.builder(
          shrinkWrap: true,
          gridDelegate:
              const flutter_material.SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: ThemeSettings.predefinedColors.length,
          itemBuilder: (context, index) {
            final color = ThemeSettings.predefinedColors[index];
            final isSelected = color.value == currentColor.value;

            return flutter_material.GestureDetector(
              onTap: () => onColorSelected(color),
              child: flutter_material.Container(
                decoration: flutter_material.BoxDecoration(
                  color: color,
                  shape: flutter_material.BoxShape.circle,
                  border: isSelected
                      ? flutter_material.Border.all(
                          color: flutter_material.Theme.of(context)
                              .colorScheme
                              .onSurface,
                          width: 3,
                        )
                      : null,
                ),
                child: isSelected
                    ? flutter_material.Icon(
                        flutter_material.Icons.check,
                        color: color.computeLuminance() > 0.5
                            ? flutter_material.Colors.black
                            : flutter_material.Colors.white,
                      )
                    : null,
              ),
            );
          },
        ),
      ),
      actions: [
        flutter_material.TextButton(
          onPressed: () => flutter_material.Navigator.of(context).pop(),
          child: const flutter_material.Text('Cancel'),
        ),
      ],
    );
  }
}

class ColorPreview extends flutter_material.StatelessWidget {
  final flutter_material.Color color;
  final flutter_material.VoidCallback onTap;

  const ColorPreview({
    super.key,
    required this.color,
    required this.onTap,
  });

  @override
  flutter_material.Widget build(flutter_material.BuildContext context) {
    return flutter_material.GestureDetector(
      onTap: onTap,
      child: flutter_material.Container(
        width: 40,
        height: 40,
        decoration: flutter_material.BoxDecoration(
          color: color,
          shape: flutter_material.BoxShape.circle,
          border: flutter_material.Border.all(
            color: flutter_material.Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
      ),
    );
  }
}

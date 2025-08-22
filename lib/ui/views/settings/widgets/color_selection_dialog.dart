import 'dart:math' as math;
import 'package:flutter/material.dart' as flutter_material;
import 'package:my_tube/models/theme_settings.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

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
      content: flutter_material.Builder(
        builder: (context) {
          // Use MediaQuery directly from this builder's context
      final mq = flutter_material.MediaQuery.of(context);
      // Use app breakpoints to determine sensible max widths for content
      final contentMax = AppBreakpoints.getContentMaxWidth(context);
      final screenLimit = mq.size.width * 0.9;
      final maxDialogWidth = contentMax.isFinite
        ? math.min(contentMax, screenLimit)
        : screenLimit;
      final maxDialogHeight = math.min(360.0, mq.size.height * 0.6);

      // Responsive item sizes
      final isTablet = AppBreakpoints.isTablet(context);
      final maxCrossAxisExtent = isTablet ? 72.0 : 64.0;
      final itemDiameter = isTablet ? 48.0 : 40.0;

          return flutter_material.ConstrainedBox(
            constraints: flutter_material.BoxConstraints(
              maxWidth: maxDialogWidth,
              maxHeight: maxDialogHeight,
            ),
            child: flutter_material.SizedBox(
              width: maxDialogWidth,
              height: maxDialogHeight,
              child: flutter_material.GridView.builder(
                shrinkWrap: true,
                gridDelegate: flutter_material
                    .SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                padding: const flutter_material.EdgeInsets.all(8),
                itemCount: ThemeSettings.predefinedColors.length,
                itemBuilder: (context, index) {
                  final color = ThemeSettings.predefinedColors[index];
                  final isSelected =
                      color.toARGB32() == currentColor.toARGB32();

                  return flutter_material.GestureDetector(
                    onTap: () => onColorSelected(color),
                    child: flutter_material.Center(
                      child: flutter_material.SizedBox(
                        width: itemDiameter,
                        height: itemDiameter,
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
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
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

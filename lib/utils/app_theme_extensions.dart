import 'package:flutter/material.dart';

/// Enhanced theme extensions for consistent styling throughout the app
/// Provides Material 3 compliant styles for cards, buttons, and other components
extension AppThemeExtensions on ThemeData {
  // Enhanced Card Styles
  /// Enhanced card theme with modern styling
  CardTheme get enhancedCardTheme => CardTheme(
        elevation: 2,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
      );

  /// Header card theme for playlist and channel headers
  CardTheme get headerCardTheme => CardTheme(
        elevation: 4,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
      );

  /// Compact card theme for video tiles
  CardTheme get compactCardTheme => CardTheme(
        elevation: 1,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        clipBehavior: Clip.antiAlias,
      );

  // Enhanced Button Styles
  /// Primary action button style (Play, Queue, etc.)
  ButtonStyle get primaryActionButtonStyle => FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );

  /// Secondary action button style (Download, Share, etc.)
  ButtonStyle get secondaryActionButtonStyle => FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 1,
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        textStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      );

  /// Icon button style for compact actions
  ButtonStyle get iconActionButtonStyle => IconButton.styleFrom(
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor:
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        foregroundColor: colorScheme.onSurfaceVariant,
      );

  /// Favorite toggle button style with heart animation support
  ButtonStyle get favoriteButtonStyle => IconButton.styleFrom(
        padding: const EdgeInsets.all(8),
        shape: const CircleBorder(),
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
      );

  /// Enhanced floating action button style
  ButtonStyle get enhancedFabStyle => ElevatedButton.styleFrom(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      );

  // Enhanced Text Styles
  /// Header title style for playlist and channel names
  TextStyle get headerTitleStyle =>
      textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
        height: 1.2,
      ) ??
      const TextStyle();

  /// Subtitle style for metadata information
  TextStyle get headerSubtitleStyle =>
      textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        height: 1.4,
      ) ??
      const TextStyle();

  /// Video title style for video tiles
  TextStyle get videoTitleStyle =>
      textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.3,
      ) ??
      const TextStyle();

  /// Video subtitle style for channel name and metadata
  TextStyle get videoSubtitleStyle =>
      textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        height: 1.2,
      ) ??
      const TextStyle();

  /// Stats text style for subscriber count, video count, etc.
  TextStyle get statsTextStyle =>
      textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ) ??
      const TextStyle();

  // Enhanced Container Styles
  /// Container decoration for image overlays
  BoxDecoration get imageOverlayDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            colorScheme.surface.withValues(alpha: 0.7),
            colorScheme.surface.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      );

  /// Container decoration for playing indicator background
  BoxDecoration get playingIndicatorDecoration => BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  /// Container decoration for action button groups
  BoxDecoration get actionGroupDecoration => BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      );

  // Enhanced Avatar Styles
  /// Avatar decoration with border and shadow
  BoxDecoration get enhancedAvatarDecoration => BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // Enhanced Divider Styles
  /// Subtle divider for separating content sections
  Divider get enhancedDivider => Divider(
        color: colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
        height: 24,
        indent: 16,
        endIndent: 16,
      );

  // Enhanced Input Decoration
  /// Input decoration for search and text fields
  InputDecoration get enhancedInputDecoration => InputDecoration(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  // Color Utilities
  /// Get appropriate text color for given background
  Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? colorScheme.onSurface : colorScheme.surface;
  }

  /// Get surface color with opacity for overlays
  Color get surfaceOverlay => colorScheme.surface.withValues(alpha: 0.9);

  /// Get primary color with reduced opacity for subtle accents
  Color get primaryAccent => colorScheme.primary.withValues(alpha: 0.1);
}

/// Extension for creating themed widgets with consistent styling
extension ThemedWidgets on BuildContext {
  /// Creates a themed card with enhanced styling
  Widget themedCard({
    required Widget child,
    CardTheme? cardTheme,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(this);
    final effectiveCardTheme = cardTheme ?? theme.enhancedCardTheme;

    return Card(
      elevation: effectiveCardTheme.elevation,
      shadowColor: effectiveCardTheme.shadowColor,
      surfaceTintColor: effectiveCardTheme.surfaceTintColor,
      shape: effectiveCardTheme.shape,
      margin: effectiveCardTheme.margin,
      clipBehavior: effectiveCardTheme.clipBehavior,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: child,
            )
          : child,
    );
  }

  /// Creates a themed action button with consistent styling
  Widget themedActionButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool isPrimary = true,
    bool isLoading = false,
  }) {
    final theme = Theme.of(this);
    final buttonStyle = isPrimary
        ? theme.primaryActionButtonStyle
        : theme.secondaryActionButtonStyle;

    if (isLoading) {
      return FilledButton.icon(
        onPressed: null,
        style: buttonStyle,
        icon: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.onPrimary.withValues(alpha: 0.7),
            ),
          ),
        ),
        label: Text(label),
      );
    }

    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: buttonStyle,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(label),
    );
  }
}

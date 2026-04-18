import 'package:flutter/material.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
export 'package:my_tube/utils/app_breakpoints.dart';

/// Signature for a widget builder that receives a [BuildContext].
typedef ResponsiveWidgetBuilder = Widget Function(BuildContext context);

/// A generic responsive layout builder that selects which widget to display
/// based on the current screen width using [AppBreakpoints].
///
/// This widget uses [LayoutBuilder] internally, so it only rebuilds when
/// the constraints change (not on every frame), making it performant.
///
/// Example usage:
/// ```dart
/// ResponsiveLayoutBuilder(
///   mobile: (_) => MobileLayout(),
///   tablet: (_) => TabletLayout(),
///   desktop: (_) => DesktopLayout(),
///   largeDesktop: (_) => LargeDesktopLayout(),
/// )
/// ```
class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  /// Widget to display on compact/mobile screens (< 600dp)
  final ResponsiveWidgetBuilder mobile;

  /// Widget to display on medium/tablet screens (600dp - 839dp).
  /// Falls back to [mobile] if not provided.
  final ResponsiveWidgetBuilder? tablet;

  /// Widget to display on expanded/desktop screens (840dp - 1199dp).
  /// Falls back to [tablet] or [mobile] if not provided.
  final ResponsiveWidgetBuilder? desktop;

  /// Widget to display on large desktop screens (>= 1200dp).
  /// Falls back to [desktop], [tablet], or [mobile] if not provided.
  final ResponsiveWidgetBuilder? largeDesktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= AppBreakpoints.large && largeDesktop != null) {
          return largeDesktop!(context);
        }
        if (width >= AppBreakpoints.expanded && desktop != null) {
          return desktop!(context);
        }
        if (width >= AppBreakpoints.compact && tablet != null) {
          return tablet!(context);
        }
        return mobile(context);
      },
    );
  }
}

/// Extension method on [BuildContext] for quick responsive checks
/// without importing [AppBreakpoints] directly in UI code.
///
/// For [isCompact], [isExpanded], [isLargeDesktop] and other base checks,
/// use the [ResponsiveContext] extension provided by [AppBreakpoints]
/// (automatically available via the export above).
extension ResponsiveContextExtension on BuildContext {
  /// Returns true if screen width is >= 600dp and < 840dp (medium/tablet)
  bool get isMedium =>
      MediaQuery.sizeOf(this).width >= AppBreakpoints.compact &&
      MediaQuery.sizeOf(this).width < AppBreakpoints.expanded;

  /// Returns true if screen width is strictly < 600dp (phone only).
  /// Use [isCompact] (from [ResponsiveContext]) for the broader < 840dp check.
  bool get isPhone => MediaQuery.sizeOf(this).width < AppBreakpoints.compact;

  /// Returns true if screen width is >= 600dp and < 840dp (alias for [isMedium])
  bool get isTabletSize => isMedium;

  /// Returns true if screen width is >= 840dp (desktop or large desktop)
  bool get isDesktopSize =>
      MediaQuery.sizeOf(this).width >= AppBreakpoints.medium;

  /// Select value based on current screen size
  T selectResponsive<T>({
    required T phone,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final width = MediaQuery.sizeOf(this).width;

    if (width >= AppBreakpoints.large && largeDesktop != null) {
      return largeDesktop;
    }
    if (width >= AppBreakpoints.expanded && desktop != null) {
      return desktop;
    }
    if (width >= AppBreakpoints.compact && tablet != null) {
      return tablet;
    }
    return phone;
  }

  /// Get responsive horizontal padding
  double get responsiveHPadding => AppBreakpoints.getHorizontalPadding(this);

  /// Get responsive vertical padding
  double get responsiveVPadding => AppBreakpoints.getVerticalPadding(this);

  /// Get responsive content max width
  double get responsiveMaxWidth => AppBreakpoints.getContentMaxWidth(this);

  /// Get responsive vertical spacing between list items
  double get responsiveSpacing => selectResponsive(
        phone: 8.0,
        tablet: 12.0,
        desktop: 16.0,
        largeDesktop: 20.0,
      );
}

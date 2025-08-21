import 'package:flutter/material.dart';

/// Responsive design utilities for consistent breakpoints and layout adaptations
/// Provides standardized breakpoints and helper methods for responsive design
class AppBreakpoints {
  // Private constructor to prevent instantiation
  AppBreakpoints._();

  // Breakpoint Constants
  /// Mobile breakpoint (up to 600dp)
  static const double mobile = 600;

  /// Tablet breakpoint (600dp to 900dp)
  static const double tablet = 900;

  /// Desktop breakpoint (900dp to 1200dp)
  static const double desktop = 1200;

  /// Large desktop breakpoint (1200dp and above)
  static const double largeDesktop = 1200;

  // Compact breakpoints for specific components
  /// Compact layout threshold for headers
  static const double compactHeader = 480;

  /// Compact layout threshold for cards
  static const double compactCard = 360;

  /// Minimum width for side-by-side layout
  static const double sideBySide = 720;

  // Device Type Detection
  /// Check if current screen size is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// Check if current screen size is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  /// Check if current screen size is desktop
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktop && width < largeDesktop;
  }

  /// Check if current screen size is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktop;
  }

  /// Check if current screen size is compact (mobile or small tablet)
  static bool isCompact(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }

  /// Check if current screen size is expanded (tablet or desktop)
  static bool isExpanded(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }

  // Layout Utilities
  /// Get appropriate number of columns for grid layouts
  static int getGridColumns(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
    int largeDesktopColumns = 4,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= largeDesktop) return largeDesktopColumns;
    if (width >= desktop) return desktopColumns;
    if (width >= tablet) return tabletColumns;
    return mobileColumns;
  }

  /// Get appropriate cross axis count for video grids
  static int getVideoGridColumns(BuildContext context) {
    return getGridColumns(
      context,
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 3,
      largeDesktopColumns: 4,
    );
  }

  /// Get appropriate cross axis count for channel/playlist grids
  static int getChannelGridColumns(BuildContext context) {
    return getGridColumns(
      context,
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 2,
      largeDesktopColumns: 3,
    );
  }

  /// Get appropriate horizontal padding based on screen size
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= largeDesktop) return 32.0;
    if (width >= desktop) return 24.0;
    if (width >= tablet) return 20.0;
    return 16.0;
  }

  /// Get appropriate vertical padding based on screen size
  static double getVerticalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= desktop) return 24.0;
    if (width >= tablet) return 20.0;
    return 16.0;
  }

  /// Get appropriate content max width for readability
  static double getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= largeDesktop) return 1200.0;
    if (width >= desktop) return 900.0;
    return double.infinity;
  }

  // Component-Specific Utilities
  /// Check if header should use compact layout
  static bool shouldUseCompactHeader(BuildContext context) {
    return MediaQuery.of(context).size.width < compactHeader;
  }

  /// Check if cards should use compact layout
  static bool shouldUseCompactCards(BuildContext context) {
    return MediaQuery.of(context).size.width < compactCard;
  }

  /// Check if layout should be side-by-side (e.g., image + content)
  static bool shouldUseSideBySideLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= sideBySide;
  }

  /// Get appropriate aspect ratio for video thumbnails
  static double getVideoThumbnailAspectRatio(BuildContext context) {
    if (isMobile(context)) return 16 / 9;
    if (isTablet(context)) return 16 / 9;
    return 16 / 9; // Consistent aspect ratio across all devices
  }

  /// Get appropriate image size for channel avatars
  static double getChannelAvatarSize(BuildContext context) {
    if (isMobile(context)) return 64.0;
    if (isTablet(context)) return 80.0;
    return 96.0;
  }

  /// Get appropriate font scale factor for different screen sizes
  static double getFontScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= largeDesktop) return 1.1;
    if (width >= desktop) return 1.05;
    if (width >= tablet) return 1.0;
    return 0.95;
  }

  // Responsive Value Selection
  /// Select value based on current breakpoint
  static T selectByBreakpoint<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= AppBreakpoints.largeDesktop && largeDesktop != null) {
      return largeDesktop;
    }
    if (width >= AppBreakpoints.desktop && desktop != null) {
      return desktop;
    }
    if (width >= AppBreakpoints.tablet && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive EdgeInsets
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? largeDesktop,
  }) {
    return selectByBreakpoint(
      context,
      mobile: mobile ?? const EdgeInsets.all(16),
      tablet: tablet ?? const EdgeInsets.all(20),
      desktop: desktop ?? const EdgeInsets.all(24),
      largeDesktop: largeDesktop ?? const EdgeInsets.all(32),
    );
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? largeDesktop,
  }) {
    return selectByBreakpoint(
      context,
      mobile: mobile ?? const EdgeInsets.all(8),
      tablet: tablet ?? const EdgeInsets.all(12),
      desktop: desktop ?? const EdgeInsets.all(16),
      largeDesktop: largeDesktop ?? const EdgeInsets.all(20),
    );
  }

  /// Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(
    BuildContext context, {
    BorderRadius? mobile,
    BorderRadius? tablet,
    BorderRadius? desktop,
    BorderRadius? largeDesktop,
  }) {
    return selectByBreakpoint(
      context,
      mobile: mobile ?? BorderRadius.circular(12),
      tablet: tablet ?? BorderRadius.circular(16),
      desktop: desktop ?? BorderRadius.circular(20),
      largeDesktop: largeDesktop ?? BorderRadius.circular(24),
    );
  }
}

/// Extension for easy access to responsive utilities from BuildContext
extension ResponsiveContext on BuildContext {
  /// Check if current screen is mobile
  bool get isMobile => AppBreakpoints.isMobile(this);

  /// Check if current screen is tablet
  bool get isTablet => AppBreakpoints.isTablet(this);

  /// Check if current screen is desktop
  bool get isDesktop => AppBreakpoints.isDesktop(this);

  /// Check if current screen is large desktop
  bool get isLargeDesktop => AppBreakpoints.isLargeDesktop(this);

  /// Check if current screen is compact
  bool get isCompact => AppBreakpoints.isCompact(this);

  /// Check if current screen is expanded
  bool get isExpanded => AppBreakpoints.isExpanded(this);

  /// Get responsive horizontal padding
  double get responsiveHorizontalPadding =>
      AppBreakpoints.getHorizontalPadding(this);

  /// Get responsive vertical padding
  double get responsiveVerticalPadding =>
      AppBreakpoints.getVerticalPadding(this);

  /// Get responsive content max width
  double get responsiveContentMaxWidth =>
      AppBreakpoints.getContentMaxWidth(this);

  /// Select value based on current breakpoint
  T selectByBreakpoint<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) =>
      AppBreakpoints.selectByBreakpoint(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
        largeDesktop: largeDesktop,
      );

  /// Get responsive padding
  EdgeInsets get responsivePadding => AppBreakpoints.getResponsivePadding(this);

  /// Get responsive margin
  EdgeInsets get responsiveMargin => AppBreakpoints.getResponsiveMargin(this);

  /// Get responsive border radius
  BorderRadius get responsiveBorderRadius =>
      AppBreakpoints.getResponsiveBorderRadius(this);

  /// Get responsive vertical spacing for list items
  double get responsiveVerticalSpacing => selectByBreakpoint(
        mobile: 8.0,
        tablet: 12.0,
        desktop: 16.0,
        largeDesktop: 20.0,
      );

  /// Get responsive horizontal spacing for action buttons
  double get responsiveHorizontalSpacing => selectByBreakpoint(
        mobile: 6.0,
        tablet: 8.0,
        desktop: 12.0,
        largeDesktop: 16.0,
      );
}

import 'package:flutter/material.dart';

/// Responsive design utilities for consistent breakpoints and layout adaptations
/// Provides standardized breakpoints and helper methods for responsive design
///
/// Breakpoints follow Material Design 3 responsive layout guidelines:
/// - Compact (phone): < 600dp
/// - Medium (tablet): 600dp - 839dp
/// - Expanded (desktop): >= 840dp
/// - Large desktop: >= 1200dp
class AppBreakpoints {
  // Private constructor to prevent instantiation
  AppBreakpoints._();

  // Breakpoint Constants
  /// Compact/mobile breakpoint (up to 600dp)
  static const double compact = 600;

  /// Medium/tablet breakpoint (600dp to 840dp)
  static const double medium = 840;

  /// Expanded/desktop breakpoint (840dp to 1199dp)
  static const double expanded = 840;

  /// Large desktop breakpoint (1200dp and above)
  static const double large = 1200;

  // Legacy aliases for backward compatibility
  /// @deprecated Use [compact] instead
  static double get mobile => compact;

  /// @deprecated Use [medium] instead
  static double get tablet => medium;

  /// @deprecated Use [expanded] instead
  static double get desktop => large;

  /// @deprecated Use [large] instead
  static double get largeDesktop => large;

  // Compact breakpoints for specific components
  /// Compact layout threshold for headers
  static const double compactHeader = 480;

  /// Compact layout threshold for cards
  static const double compactCard = 360;

  /// Minimum width for side-by-side layout
  static const double sideBySide = 720;

  // Device Type Detection
  /// Check if current screen is compact (phone, < 600dp)
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compact;
  }

  /// Check if current screen is medium (tablet, 600dp - 839dp)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < expanded;
  }

  /// Check if current screen is expanded (desktop, 840dp - 1199dp)
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= expanded && width < large;
  }

  /// Check if current screen is large desktop (>= 1200dp)
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= large;
  }

  /// Check if current screen is compact (mobile or small tablet, < 840dp)
  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < medium;
  }

  /// Check if current screen is expanded (tablet or desktop, >= 840dp)
  static bool isExpanded(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= medium;
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
    final width = MediaQuery.sizeOf(context).width;

    if (width >= large) return largeDesktopColumns;
    if (width >= expanded) return desktopColumns;
    if (width >= compact) return tabletColumns;
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
    final width = MediaQuery.sizeOf(context).width;

    if (width >= large) return 32.0;
    if (width >= expanded) return 24.0;
    if (width >= compact) return 20.0;
    return 16.0;
  }

  /// Get appropriate vertical padding based on screen size
  static double getVerticalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= expanded) return 24.0;
    if (width >= compact) return 20.0;
    return 16.0;
  }

  /// Get appropriate content max width for readability
  static double getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= large) return 1200.0;
    if (width >= expanded) return 900.0;
    return double.infinity;
  }

  // Component-Specific Utilities
  /// Check if header should use compact layout
  static bool shouldUseCompactHeader(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compactHeader;
  }

  /// Check if cards should use compact layout
  static bool shouldUseCompactCards(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compactCard;
  }

  /// Check if layout should be side-by-side (e.g., image + content)
  static bool shouldUseSideBySideLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= sideBySide;
  }

  /// Get appropriate aspect ratio for video thumbnails
  static double getVideoThumbnailAspectRatio(BuildContext context) {
    return 16 / 9; // Consistent across all devices
  }

  /// Get appropriate image size for channel avatars
  static double getChannelAvatarSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compact) return 64.0;
    if (width < expanded) return 80.0;
    return 96.0;
  }

  /// Get responsive font scale factor
  static double getFontScaleFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= large) return 1.1;
    if (width >= expanded) return 1.05;
    if (width >= compact) return 1.0;
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
    final width = MediaQuery.sizeOf(context).width;

    if (width >= AppBreakpoints.large && largeDesktop != null) {
      return largeDesktop;
    }
    if (width >= AppBreakpoints.expanded && desktop != null) {
      return desktop;
    }
    if (width >= AppBreakpoints.compact && tablet != null) {
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

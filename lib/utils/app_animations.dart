import 'package:flutter/material.dart';

/// Centralized animation constants for consistent animations throughout the app
/// Provides standardized durations and curves for different types of animations
class AppAnimations {
  // Private constructor to prevent instantiation
  AppAnimations._();

  // Animation Durations
  /// Fast animations for quick feedback (200ms)
  static const Duration fast = Duration(milliseconds: 200);

  /// Medium animations for standard transitions (300ms)
  static const Duration medium = Duration(milliseconds: 300);

  /// Slow animations for complex transitions (500ms)
  static const Duration slow = Duration(milliseconds: 500);

  /// Extra slow animations for hero transitions (800ms)
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Animation Curves
  /// Standard ease in out curve for most animations
  static const Curve easeInOut = Curves.easeInOut;

  /// Ease out curve for entrance animations
  static const Curve easeOut = Curves.easeOut;

  /// Ease in curve for exit animations
  static const Curve easeIn = Curves.easeIn;

  /// Bounce curve for playful interactions
  static const Curve bounce = Curves.elasticOut;

  /// Smooth curve for subtle animations
  static const Curve smooth = Curves.easeInOutCubic;

  /// Sharp curve for quick snappy animations
  static const Curve sharp = Curves.easeInOutQuart;

  // Specific Animation Configurations
  /// Configuration for button press animations
  static const Duration buttonPress = fast;
  static const Curve buttonCurve = easeOut;

  /// Configuration for page transitions
  static const Duration pageTransition = medium;
  static const Curve pageTransitionCurve = easeInOut;

  /// Configuration for loading animations
  static const Duration loading = slow;
  static const Curve loadingCurve = easeInOut;

  /// Configuration for favorite toggle animations
  static const Duration favoriteToggle = medium;
  static const Curve favoriteCurve = bounce;

  /// Configuration for card hover animations
  static const Duration cardHover = fast;
  static const Curve cardHoverCurve = easeOut;

  /// Configuration for list item animations
  static const Duration listItem = medium;
  static const Curve listItemCurve = easeInOut;

  // Animation Values
  /// Standard elevation for hover states
  static const double hoverElevation = 8.0;

  /// Standard elevation for pressed states
  static const double pressedElevation = 2.0;

  /// Standard scale factor for button press
  static const double buttonPressScale = 0.95;

  /// Standard scale factor for card hover
  static const double cardHoverScale = 1.02;

  // Helper methods for common animations
  /// Creates a standard fade transition
  static Widget fadeTransition({
    required Animation<double> animation,
    required Widget child,
    Duration duration = medium,
    Curve curve = easeInOut,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: curve,
      ),
      child: child,
    );
  }

  /// Creates a standard scale transition
  static Widget scaleTransition({
    required Animation<double> animation,
    required Widget child,
    Duration duration = medium,
    Curve curve = easeInOut,
    Alignment alignment = Alignment.center,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: curve,
      ),
      alignment: alignment,
      child: child,
    );
  }

  /// Creates a standard slide transition
  static Widget slideTransition({
    required Animation<double> animation,
    required Widget child,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Duration duration = medium,
    Curve curve = easeInOut,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      child: child,
    );
  }
}

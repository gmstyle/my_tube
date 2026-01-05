import 'package:flutter/material.dart';
import 'package:my_tube/utils/app_animations.dart';

/// A container that implements Material 3 state specifications for hover/focus.
/// It creates a "lift" effect by increasing elevation and changing surface tint on hover.
class MaterialHoverContainer extends StatefulWidget {
  const MaterialHoverContainer({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.padding,
    this.fillColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? fillColor;

  @override
  State<MaterialHoverContainer> createState() => _MaterialHoverContainerState();
}

class _MaterialHoverContainerState extends State<MaterialHoverContainer> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Material 3 Specs:
    // Card defaults: Elevation 1 (Low), Surface Container Low
    // Hover: Elevation 2-4, Surface Container High/Highest

    final double elevation = _isPressed
        ? 1.0
        : _isHovered
            ? 3.0
            : 1.0;

    final Color effectiveFillColor = widget.fillColor ??
        (_isHovered
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerLow);

    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(12);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedPhysicalModel(
          curve: AppAnimations.cardHoverCurve,
          duration: AppAnimations.cardHover,
          shape: BoxShape.rectangle,
          elevation: elevation,
          color: effectiveFillColor,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          borderRadius:
              effectiveBorderRadius.resolve(Directionality.of(context)),
          child: ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A wrapper for images that adds subtle interactivity and follows M3 shape guidelines.
class ExpressiveImage extends StatefulWidget {
  const ExpressiveImage({
    super.key,
    required this.child,
    this.borderRadius,
    this.scaleOnHover = true,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final bool scaleOnHover;

  @override
  State<ExpressiveImage> createState() => _ExpressiveImageState();
}

class _ExpressiveImageState extends State<ExpressiveImage> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        child: AnimatedScale(
          scale: (widget.scaleOnHover && _isHovered) ? 1.05 : 1.0,
          duration: AppAnimations.cardHover, // Using standard duration
          curve: AppAnimations.cardHoverCurve,
          child: widget.child,
        ),
      ),
    );
  }
}

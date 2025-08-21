import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:my_tube/utils/app_animations.dart';

/// Scroll-based animation utilities for enhanced user experience
/// Provides smooth animations triggered by scroll events
class ScrollAnimations {
  ScrollAnimations._();

  /// Creates a scroll-aware fade-in animation for list items
  static Widget scrollFadeIn({
    required Widget child,
    required int index,
    Duration delay = Duration.zero,
    Duration duration = AppAnimations.medium,
    Curve curve = AppAnimations.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration + Duration(milliseconds: index * 50),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Creates a scroll-aware slide-in animation from the side
  static Widget scrollSlideIn({
    required Widget child,
    required int index,
    bool fromLeft = false,
    Duration delay = Duration.zero,
    Duration duration = AppAnimations.medium,
    Curve curve = AppAnimations.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration + Duration(milliseconds: index * 75),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        final slideOffset = fromLeft ? -30.0 : 30.0;
        return Transform.translate(
          offset: Offset(slideOffset * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Creates a scroll-aware scale animation
  static Widget scrollScaleIn({
    required Widget child,
    required int index,
    Duration delay = Duration.zero,
    Duration duration = AppAnimations.medium,
    Curve curve = AppAnimations.easeOut,
    double initialScale = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration + Duration(milliseconds: index * 60),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        final scale = initialScale + (1.0 - initialScale) * value;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Creates a staggered animation for multiple children
  static List<Widget> staggeredChildren({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration duration = AppAnimations.medium,
    Curve curve = AppAnimations.easeOut,
    ScrollAnimationType type = ScrollAnimationType.fadeIn,
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;

      switch (type) {
        case ScrollAnimationType.fadeIn:
          return scrollFadeIn(
            child: child,
            index: index,
            duration: duration,
            curve: curve,
          );
        case ScrollAnimationType.slideInLeft:
          return scrollSlideIn(
            child: child,
            index: index,
            fromLeft: true,
            duration: duration,
            curve: curve,
          );
        case ScrollAnimationType.slideInRight:
          return scrollSlideIn(
            child: child,
            index: index,
            fromLeft: false,
            duration: duration,
            curve: curve,
          );
        case ScrollAnimationType.scaleIn:
          return scrollScaleIn(
            child: child,
            index: index,
            duration: duration,
            curve: curve,
          );
      }
    }).toList();
  }
}

/// Types of scroll-based animations available
enum ScrollAnimationType {
  fadeIn,
  slideInLeft,
  slideInRight,
  scaleIn,
}

/// Widget that provides scroll-based visibility animations
class ScrollVisibilityAnimator extends StatefulWidget {
  const ScrollVisibilityAnimator({
    super.key,
    required this.child,
    this.animationType = ScrollAnimationType.fadeIn,
    this.duration = AppAnimations.medium,
    this.curve = AppAnimations.easeOut,
    this.threshold = 0.1,
  });

  final Widget child;
  final ScrollAnimationType animationType;
  final Duration duration;
  final Curve curve;
  final double threshold;

  @override
  State<ScrollVisibilityAnimator> createState() =>
      _ScrollVisibilityAnimatorState();
}

class _ScrollVisibilityAnimatorState extends State<ScrollVisibilityAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Start animation after a brief delay to ensure proper mounting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkVisibility();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        switch (widget.animationType) {
          case ScrollAnimationType.fadeIn:
            return Transform.translate(
              offset: Offset(0, 20 * (1 - _animation.value)),
              child: Opacity(
                opacity: _animation.value,
                child: widget.child,
              ),
            );
          case ScrollAnimationType.slideInLeft:
            return Transform.translate(
              offset: Offset(-30 * (1 - _animation.value), 0),
              child: Opacity(
                opacity: _animation.value,
                child: widget.child,
              ),
            );
          case ScrollAnimationType.slideInRight:
            return Transform.translate(
              offset: Offset(30 * (1 - _animation.value), 0),
              child: Opacity(
                opacity: _animation.value,
                child: widget.child,
              ),
            );
          case ScrollAnimationType.scaleIn:
            return Transform.scale(
              scale: 0.8 + (0.2 * _animation.value),
              child: Opacity(
                opacity: _animation.value,
                child: widget.child,
              ),
            );
        }
      },
    );
  }
}

/// Enhanced loading animation with pulsing effect
class PulsingLoadingAnimation extends StatefulWidget {
  const PulsingLoadingAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    this.minOpacity = 0.3,
    this.maxOpacity = 1.0,
  });

  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  @override
  State<PulsingLoadingAnimation> createState() =>
      _PulsingLoadingAnimationState();
}

class _PulsingLoadingAnimationState extends State<PulsingLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Heart animation for favorite button with enhanced effects
class HeartBurstAnimation extends StatefulWidget {
  const HeartBurstAnimation({
    super.key,
    required this.child,
    required this.isAnimating,
    this.duration = AppAnimations.medium,
    this.particleCount = 6,
  });

  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final int particleCount;

  @override
  State<HeartBurstAnimation> createState() => _HeartBurstAnimationState();
}

class _HeartBurstAnimationState extends State<HeartBurstAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(milliseconds: widget.duration.inMilliseconds + 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HeartBurstAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
      _particleController.forward().then((_) {
        _particleController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _particleController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Particle effects
            if (_particleAnimation.value > 0) ..._buildParticles(),
            // Main heart with scale animation
            Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildParticles() {
    final particles = <Widget>[];
    final theme = Theme.of(context);

    for (int i = 0; i < widget.particleCount; i++) {
      final angle = (i * 2 * 3.14159) / widget.particleCount;
      final distance = 30 * _particleAnimation.value;
      final x = distance * math.cos(angle);
      final y = distance * math.sin(angle);

      particles.add(
        Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: 1.0 - _particleAnimation.value,
            child: Opacity(
              opacity: 1.0 - _particleAnimation.value,
              child: Icon(
                Icons.favorite,
                size: 8,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    return particles;
  }
}

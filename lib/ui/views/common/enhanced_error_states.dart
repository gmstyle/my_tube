import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

/// Enhanced error state widget with recovery actions and animations
class EnhancedErrorState extends StatefulWidget {
  const EnhancedErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.onGoBack,
    this.icon = Icons.error_outline,
    this.showRetryButton = true,
    this.showBackButton = true,
    this.customActions,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onGoBack;
  final IconData icon;
  final bool showRetryButton;
  final bool showBackButton;
  final List<Widget>? customActions;

  @override
  State<EnhancedErrorState> createState() => _EnhancedErrorStateState();
}

class _EnhancedErrorStateState extends State<EnhancedErrorState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: SingleChildScrollView(
              padding: context.responsivePadding,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: context.responsiveContentMaxWidth,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated error icon
                      Transform.scale(
                        scale: _iconScaleAnimation.value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            size: 40,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Error title
                      Text(
                        widget.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Error message
                      Text(
                        widget.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 32),

                      // Action buttons
                      _buildActionButtons(context, theme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    if (widget.customActions != null) {
      return Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: widget.customActions!,
      );
    }

    final actions = <Widget>[];

    if (widget.showRetryButton) {
      actions.add(
        EnhancedPrimaryActionButton(
          label: 'Try Again',
          icon: Icons.refresh,
          onPressed: widget.onRetry,
          isPrimary: true,
        ),
      );
    }

    if (widget.showBackButton && widget.onGoBack != null) {
      actions.add(
        EnhancedPrimaryActionButton(
          label: 'Go Back',
          icon: Icons.arrow_back,
          onPressed: widget.onGoBack!,
          isPrimary: false,
        ),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: actions,
    );
  }
}

/// Enhanced empty state widget with appropriate illustrations
class EnhancedEmptyState extends StatefulWidget {
  const EnhancedEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
    this.actionIcon,
    this.illustration,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData? actionIcon;
  final Widget? illustration;

  @override
  State<EnhancedEmptyState> createState() => _EnhancedEmptyStateState();
}

class _EnhancedEmptyStateState extends State<EnhancedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: SingleChildScrollView(
              padding: context.responsivePadding,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: context.responsiveContentMaxWidth,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration or icon
                      widget.illustration ??
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.icon,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                      const SizedBox(height: 32),

                      // Title
                      Text(
                        widget.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Message
                      Text(
                        widget.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Action button
                      if (widget.onAction != null && widget.actionLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: EnhancedPrimaryActionButton(
                            label: widget.actionLabel!,
                            icon: widget.actionIcon ?? Icons.refresh,
                            onPressed: widget.onAction!,
                            isPrimary: false,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Enhanced loading state with progress indicator and message
class EnhancedLoadingState extends StatefulWidget {
  const EnhancedLoadingState({
    super.key,
    this.message = 'Loading...',
    this.showProgress = false,
    this.progress,
    this.onCancel,
  });

  final String message;
  final bool showProgress;
  final double? progress;
  final VoidCallback? onCancel;

  @override
  State<EnhancedLoadingState> createState() => _EnhancedLoadingStateState();
}

class _EnhancedLoadingStateState extends State<EnhancedLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: context.responsiveContentMaxWidth,
          ),
          padding: context.responsivePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading indicator
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: widget.showProgress && widget.progress != null
                          ? CircularProgressIndicator(
                              value: widget.progress,
                              strokeWidth: 4,
                              backgroundColor: theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            )
                          : CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Loading message
              Text(
                widget.message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              // Progress percentage
              if (widget.showProgress && widget.progress != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${(widget.progress! * 100).toInt()}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

              // Cancel button
              if (widget.onCancel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Network error state with specific recovery actions
class NetworkErrorState extends EnhancedErrorState {
  const NetworkErrorState({
    super.key,
    required super.onRetry,
    super.onGoBack,
  }) : super(
          title: 'Connection Problem',
          message:
              'Unable to connect to the internet. Please check your connection and try again.',
          icon: Icons.wifi_off,
        );
}

/// Server error state with specific recovery actions
class ServerErrorState extends EnhancedErrorState {
  const ServerErrorState({
    super.key,
    required super.onRetry,
    super.onGoBack,
  }) : super(
          title: 'Server Error',
          message:
              'The server is currently unavailable. Please try again in a few moments.',
          icon: Icons.cloud_off,
        );
}

/// Content not found error state
class ContentNotFoundState extends EnhancedErrorState {
  const ContentNotFoundState({
    super.key,
    required super.onRetry,
    super.onGoBack,
  }) : super(
          title: 'Content Not Found',
          message:
              'The requested content could not be found. It may have been removed or is no longer available.',
          icon: Icons.search_off,
        );
}

/// Empty playlist state
class EmptyPlaylistState extends EnhancedEmptyState {
  const EmptyPlaylistState({
    super.key,
    super.onAction,
  }) : super(
          title: 'No Videos in Playlist',
          message:
              'This playlist appears to be empty or the videos are no longer available.',
          icon: Icons.playlist_remove,
          actionLabel: 'Refresh',
          actionIcon: Icons.refresh,
        );
}

/// Empty channel state
class EmptyChannelState extends EnhancedEmptyState {
  const EmptyChannelState({
    super.key,
    super.onAction,
  }) : super(
          title: 'No Videos Available',
          message:
              'This channel hasn\'t uploaded any videos yet, or they may not be available.',
          icon: Icons.video_library_outlined,
          actionLabel: 'Refresh',
          actionIcon: Icons.refresh,
        );
}

/// Loading more content indicator for pagination
class LoadingMoreIndicator extends StatelessWidget {
  const LoadingMoreIndicator({
    super.key,
    this.message = 'Loading more...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

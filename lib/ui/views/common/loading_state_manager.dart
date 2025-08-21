import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/utils/app_animations.dart';

/// Enhanced loading state manager for action buttons and operations
class LoadingStateManager extends ChangeNotifier {
  final Map<String, LoadingOperation> _operations = {};

  /// Get loading state for a specific operation
  bool isLoading(String operationId) {
    return _operations[operationId]?.isLoading ?? false;
  }

  /// Get progress for a specific operation
  double? getProgress(String operationId) {
    return _operations[operationId]?.progress;
  }

  /// Get error for a specific operation
  String? getError(String operationId) {
    return _operations[operationId]?.error;
  }

  /// Start a loading operation
  void startLoading(String operationId, {String? message}) {
    _operations[operationId] = LoadingOperation(
      id: operationId,
      isLoading: true,
      message: message,
    );
    notifyListeners();
  }

  /// Update progress for an operation
  void updateProgress(String operationId, double progress, {String? message}) {
    final operation = _operations[operationId];
    if (operation != null) {
      _operations[operationId] = operation.copyWith(
        progress: progress,
        message: message,
      );
      notifyListeners();
    }
  }

  /// Complete an operation successfully
  void completeOperation(String operationId, {String? successMessage}) {
    _operations[operationId] = LoadingOperation(
      id: operationId,
      isLoading: false,
      isCompleted: true,
      message: successMessage,
    );
    notifyListeners();

    // Auto-clear after delay
    Future.delayed(const Duration(seconds: 2), () {
      _operations.remove(operationId);
      notifyListeners();
    });
  }

  /// Fail an operation with error
  void failOperation(String operationId, String error) {
    _operations[operationId] = LoadingOperation(
      id: operationId,
      isLoading: false,
      error: error,
    );
    notifyListeners();
  }

  /// Clear an operation
  void clearOperation(String operationId) {
    _operations.remove(operationId);
    notifyListeners();
  }

  /// Clear all operations
  void clearAll() {
    _operations.clear();
    notifyListeners();
  }
}

/// Data class for loading operations
class LoadingOperation {
  const LoadingOperation({
    required this.id,
    this.isLoading = false,
    this.isCompleted = false,
    this.progress,
    this.message,
    this.error,
  });

  final String id;
  final bool isLoading;
  final bool isCompleted;
  final double? progress;
  final String? message;
  final String? error;

  LoadingOperation copyWith({
    String? id,
    bool? isLoading,
    bool? isCompleted,
    double? progress,
    String? message,
    String? error,
  }) {
    return LoadingOperation(
      id: id ?? this.id,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }
}

/// Enhanced loading button with integrated state management
class EnhancedLoadingButton extends StatefulWidget {
  const EnhancedLoadingButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.operationId,
    this.loadingStateManager,
    this.isPrimary = true,
    this.showProgress = false,
  });

  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;
  final String? operationId;
  final LoadingStateManager? loadingStateManager;
  final bool isPrimary;
  final bool showProgress;

  @override
  State<EnhancedLoadingButton> createState() => _EnhancedLoadingButtonState();
}

class _EnhancedLoadingButtonState extends State<EnhancedLoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLocalLoading = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    widget.loadingStateManager?.addListener(_onLoadingStateChanged);
  }

  @override
  void dispose() {
    widget.loadingStateManager?.removeListener(_onLoadingStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onLoadingStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _isLoading {
    if (widget.loadingStateManager != null && widget.operationId != null) {
      return widget.loadingStateManager!.isLoading(widget.operationId!);
    }
    return _isLocalLoading;
  }

  double? get _progress {
    if (widget.loadingStateManager != null && widget.operationId != null) {
      return widget.loadingStateManager!.getProgress(widget.operationId!);
    }
    return null;
  }

  String? get _error {
    if (widget.loadingStateManager != null && widget.operationId != null) {
      return widget.loadingStateManager!.getError(widget.operationId!);
    }
    return _localError;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _handlePress,
            style: widget.isPrimary
                ? theme.filledButtonTheme.style
                : theme.outlinedButtonTheme.style,
            icon: _buildIcon(theme),
            label: Text(widget.label),
          ),
        );
      },
    );
  }

  Widget _buildIcon(ThemeData theme) {
    if (_error != null) {
      return Icon(
        Icons.error,
        color: theme.colorScheme.error,
      );
    }

    if (_isLoading) {
      if (widget.showProgress && _progress != null) {
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            value: _progress,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.onPrimary,
            ),
          ),
        );
      }

      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.onPrimary,
          ),
        ),
      );
    }

    return Icon(widget.icon);
  }

  Future<void> _handlePress() async {
    _controller.forward().then((_) => _controller.reverse());

    if (widget.loadingStateManager != null && widget.operationId != null) {
      widget.loadingStateManager!.startLoading(widget.operationId!);
    } else {
      setState(() {
        _isLocalLoading = true;
        _localError = null;
      });
    }

    try {
      await widget.onPressed();

      if (widget.loadingStateManager != null && widget.operationId != null) {
        widget.loadingStateManager!.completeOperation(widget.operationId!);
      } else {
        setState(() {
          _isLocalLoading = false;
        });
      }
    } catch (error) {
      if (widget.loadingStateManager != null && widget.operationId != null) {
        widget.loadingStateManager!.failOperation(
          widget.operationId!,
          error.toString(),
        );
      } else {
        setState(() {
          _isLocalLoading = false;
          _localError = error.toString();
        });
      }
    }
  }
}

/// Enhanced loading overlay for full-screen operations
class EnhancedLoadingOverlay extends StatelessWidget {
  const EnhancedLoadingOverlay({
    super.key,
    required this.isVisible,
    required this.child,
    this.message = 'Loading...',
    this.progress,
    this.onCancel,
  });

  final bool isVisible;
  final Widget child;
  final String message;
  final double? progress;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: EnhancedLoadingState(
              message: message,
              showProgress: progress != null,
              progress: progress,
              onCancel: onCancel,
            ),
          ),
      ],
    );
  }
}

/// Mixin for widgets that need loading state management
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  LoadingStateManager? _loadingStateManager;

  LoadingStateManager get loadingStateManager {
    _loadingStateManager ??= LoadingStateManager();
    return _loadingStateManager!;
  }

  @override
  void dispose() {
    _loadingStateManager?.dispose();
    super.dispose();
  }

  /// Start a loading operation with optional progress tracking
  void startLoading(String operationId, {String? message}) {
    loadingStateManager.startLoading(operationId, message: message);
  }

  /// Update progress for an operation
  void updateProgress(String operationId, double progress, {String? message}) {
    loadingStateManager.updateProgress(operationId, progress, message: message);
  }

  /// Complete an operation successfully
  void completeOperation(String operationId, {String? successMessage}) {
    loadingStateManager.completeOperation(operationId,
        successMessage: successMessage);
  }

  /// Fail an operation with error
  void failOperation(String operationId, String error) {
    loadingStateManager.failOperation(operationId, error);
  }

  /// Check if an operation is loading
  bool isLoading(String operationId) {
    return loadingStateManager.isLoading(operationId);
  }

  /// Get progress for an operation
  double? getProgress(String operationId) {
    return loadingStateManager.getProgress(operationId);
  }

  /// Get error for an operation
  String? getError(String operationId) {
    return loadingStateManager.getError(operationId);
  }
}

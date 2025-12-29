import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/services/download_service.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';
import 'package:my_tube/utils/scroll_animations.dart';

/// Enhanced action button system for primary actions (Play, Queue)
/// Provides consistent styling and loading states integration
class EnhancedPrimaryActionButton extends StatefulWidget {
  const EnhancedPrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.isExpanded = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final bool isExpanded;

  @override
  State<EnhancedPrimaryActionButton> createState() =>
      _EnhancedPrimaryActionButtonState();
}

class _EnhancedPrimaryActionButtonState
    extends State<EnhancedPrimaryActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: AppAnimations.buttonPress,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.buttonPressScale,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: AppAnimations.buttonCurve,
    ));

    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.pressedElevation,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: AppAnimations.buttonCurve,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = widget.isPrimary
        ? theme.primaryActionButtonStyle
        : theme.secondaryActionButtonStyle;

    Widget button = AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null && !widget.isLoading
                ? _onTapDown
                : null,
            onTapUp:
                widget.onPressed != null && !widget.isLoading ? _onTapUp : null,
            onTapCancel: widget.onPressed != null && !widget.isLoading
                ? _onTapCancel
                : null,
            child: widget.isLoading
                ? FilledButton.icon(
                    onPressed: null,
                    style: buttonStyle,
                    icon: TweenAnimationBuilder<double>(
                      duration: AppAnimations.medium,
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 2 * 3.14159,
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    label: Text(widget.label),
                  )
                : FilledButton.icon(
                    onPressed: widget.onPressed,
                    style: buttonStyle.copyWith(
                      elevation:
                          WidgetStateProperty.all(_elevationAnimation.value),
                    ),
                    icon: Icon(widget.icon),
                    label: Text(widget.label),
                  ),
          ),
        );
      },
    );

    return widget.isExpanded ? Expanded(child: button) : button;
  }
}

/// Enhanced favorite toggle button with heart animation and visual feedback
/// Supports different entity types (video, playlist, channel)
class EnhancedFavoriteButton extends StatefulWidget {
  const EnhancedFavoriteButton({
    super.key,
    required this.entityId,
    required this.entityType,
    this.size = 24.0,
    this.showLabel = false,
    this.padding,
  });

  final String entityId;
  final FavoriteEntityType entityType;
  final double size;
  final bool showLabel;
  final EdgeInsetsGeometry? padding;

  @override
  State<EnhancedFavoriteButton> createState() => _EnhancedFavoriteButtonState();
}

class _EnhancedFavoriteButtonState extends State<EnhancedFavoriteButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _heartController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _heartController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.bounce,
    ));

    _heartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: AppAnimations.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _animateFavoriteToggle(bool isFavorite) {
    if (isFavorite) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
      _heartController.forward();
    } else {
      _heartController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<FavoritesVideoBloc, FavoritesVideoState>(
      builder: (context, videoState) {
        return BlocBuilder<FavoritesPlaylistBloc, FavoritesPlaylistState>(
          builder: (context, playlistState) {
            return BlocBuilder<FavoritesChannelBloc, FavoritesChannelState>(
              builder: (context, channelState) {
                final isFavorite = _getIsFavorite(context);

                return HeartBurstAnimation(
                  isAnimating: _scaleController.isAnimating,
                  child: AnimatedBuilder(
                    animation:
                        Listenable.merge([_scaleAnimation, _heartAnimation]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: widget.showLabel
                            ? _buildLabeledButton(context, theme, isFavorite)
                            : _buildIconButton(context, theme, isFavorite),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildIconButton(
      BuildContext context, ThemeData theme, bool isFavorite) {
    return IconButton(
      style: theme.favoriteButtonStyle.copyWith(
        padding: widget.padding != null
            ? WidgetStateProperty.all(widget.padding)
            : null,
      ),
      onPressed: () => _toggleFavorite(context, isFavorite),
      icon: AnimatedSwitcher(
        duration: AppAnimations.fast,
        child: Stack(
          key: ValueKey(isFavorite),
          alignment: Alignment.center,
          children: [
            Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: widget.size,
              color: isFavorite
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            if (isFavorite)
              AnimatedBuilder(
                animation: _heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_heartAnimation.value * 0.3),
                    child: Opacity(
                      opacity: 1.0 - _heartAnimation.value,
                      child: Icon(
                        Icons.favorite,
                        size: widget.size,
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }

  Widget _buildLabeledButton(
      BuildContext context, ThemeData theme, bool isFavorite) {
    return FilledButton.icon(
      style: theme.secondaryActionButtonStyle,
      onPressed: () => _toggleFavorite(context, isFavorite),
      icon: AnimatedSwitcher(
        duration: AppAnimations.fast,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFavorite),
          size: widget.size,
          color: isFavorite
              ? theme.colorScheme.error
              : theme.colorScheme.onSecondaryContainer,
        ),
      ),
      label: Text(isFavorite ? 'Remove from favorites' : 'Add to favorites'),
    );
  }

  bool _getIsFavorite(BuildContext context) {
    switch (widget.entityType) {
      case FavoriteEntityType.video:
        return context
            .read<FavoritesVideoBloc>()
            .favoritesRepository
            .videoIds
            .contains(widget.entityId);
      case FavoriteEntityType.playlist:
        return context
            .read<FavoritesPlaylistBloc>()
            .favoritesRepository
            .playlistIds
            .contains(widget.entityId);
      case FavoriteEntityType.channel:
        return context
            .read<FavoritesChannelBloc>()
            .favoritesRepository
            .channelIds
            .contains(widget.entityId);
    }
  }

  void _toggleFavorite(BuildContext context, bool isFavorite) {
    _animateFavoriteToggle(!isFavorite);

    switch (widget.entityType) {
      case FavoriteEntityType.video:
        final bloc = context.read<FavoritesVideoBloc>();
        if (isFavorite) {
          bloc.add(RemoveFromFavorites(widget.entityId));
        } else {
          bloc.add(AddToFavorites(widget.entityId));
        }
        break;
      case FavoriteEntityType.playlist:
        final bloc = context.read<FavoritesPlaylistBloc>();
        if (isFavorite) {
          bloc.add(RemoveFromFavoritesPlaylist(widget.entityId));
        } else {
          bloc.add(AddToFavoritesPlaylist(widget.entityId));
        }
        break;
      case FavoriteEntityType.channel:
        final bloc = context.read<FavoritesChannelBloc>();
        if (isFavorite) {
          bloc.add(RemoveFromFavoritesChannel(widget.entityId));
        } else {
          bloc.add(AddToFavoritesChannel(widget.entityId));
        }
        break;
    }
  }
}

/// Enhanced overflow menu system for secondary actions (Download, Share)
/// Provides consistent styling and organization of less frequent actions
class EnhancedOverflowMenu extends StatelessWidget {
  const EnhancedOverflowMenu({
    super.key,
    required this.actions,
    this.icon = Icons.more_vert,
    this.tooltip = 'More options',
    this.iconSize,
    this.padding,
  });

  final List<OverflowMenuAction> actions;
  final IconData icon;
  final String tooltip;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<int>(
      icon: Icon(
        icon,
        size: iconSize,
      ),
      tooltip: tooltip,
      style: theme.iconActionButtonStyle.copyWith(
        padding: padding != null ? WidgetStateProperty.all(padding) : null,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
      surfaceTintColor: theme.colorScheme.surfaceTint,
      itemBuilder: (context) {
        return actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;

          return PopupMenuItem<int>(
            value: index,
            enabled: action.isEnabled,
            child: ListTile(
              leading: Icon(
                action.icon,
                color: action.isEnabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
              title: Text(
                action.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: action.isEnabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
              subtitle: action.subtitle != null
                  ? Text(
                      action.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          );
        }).toList();
      },
      onSelected: (index) {
        if (index >= 0 && index < actions.length) {
          actions[index].onTap();
        }
      },
    );
  }
}

/// Enhanced download action button with loading states and options
class EnhancedDownloadButton extends StatefulWidget {
  const EnhancedDownloadButton({
    super.key,
    required this.videos,
    this.destinationDir,
    this.showAsIcon = false,
    this.size,
  });

  final List<Map<String, String>> videos;
  final String? destinationDir;
  final bool showAsIcon;
  final double? size;

  @override
  State<EnhancedDownloadButton> createState() => _EnhancedDownloadButtonState();
}

class _EnhancedDownloadButtonState extends State<EnhancedDownloadButton> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final downloadService = context.read<DownloadService>();

    if (widget.showAsIcon) {
      final iconSize = widget.size ?? 24.0;

      return IconButton(
        style: theme.iconActionButtonStyle,
        onPressed: _isDownloading
            ? null
            : () => _showDownloadOptions(context, downloadService),
        icon: _isDownloading
            ? SizedBox(
                width: iconSize * 0.8,
                height: iconSize * 0.8,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : Icon(
                Icons.download,
                size: iconSize,
              ),
        tooltip: 'Download options',
      );
    }

    return EnhancedPrimaryActionButton(
      label: 'Download',
      icon: Icons.download,
      isLoading: _isDownloading,
      isPrimary: false,
      onPressed: _isDownloading
          ? null
          : () => _showDownloadOptions(context, downloadService),
    );
  }

  void _showDownloadOptions(
      BuildContext context, DownloadService downloadService) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: const Text('Download Options'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.video_library,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Download Video'),
                subtitle: const Text('Full quality video with audio'),
                onTap: () {
                  Navigator.of(context).pop();
                  _startDownload(downloadService, false);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.music_note,
                  color: theme.colorScheme.secondary,
                ),
                title: const Text('Download Audio Only'),
                subtitle: const Text('Audio track only, smaller file size'),
                onTap: () {
                  Navigator.of(context).pop();
                  _startDownload(downloadService, true);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _startDownload(DownloadService downloadService, bool isAudioOnly) {
    setState(() {
      _isDownloading = true;
    });

    downloadService
        .download(
      videos: widget.videos,
      destinationDir: widget.destinationDir,
      context: context,
      isAudioOnly: isAudioOnly,
    )
        .then((_) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Download ${isAudioOnly ? 'audio' : 'video'} completed'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        // Show error feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Download failed: ${error.toString()}'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _startDownload(downloadService, isAudioOnly),
            ),
          ),
        );
      }
    });
  }
}

/// Action button group for organizing multiple actions
class EnhancedActionButtonGroup extends StatelessWidget {
  const EnhancedActionButtonGroup({
    super.key,
    required this.children,
    this.spacing = 12.0,
    this.runSpacing = 8.0,
    this.alignment = WrapAlignment.start,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      children: children,
    );
  }
}

/// Data classes for overflow menu actions
class OverflowMenuAction {
  const OverflowMenuAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.isEnabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? subtitle;
  final bool isEnabled;
}

/// Enum for different entity types that can be favorited
enum FavoriteEntityType {
  video,
  playlist,
  channel,
}

/// Helper extension for creating common action button combinations
extension ActionButtonHelpers on BuildContext {
  /// Creates a standard play/queue action group
  Widget buildPlayQueueActions({
    required List<String> videoIds,
    bool isLoading = false,
  }) {
    final playerCubit = read<PlayerCubit>();

    return EnhancedActionButtonGroup(
      children: [
        EnhancedPrimaryActionButton(
          label: 'Play All',
          icon: Icons.play_arrow_rounded,
          onPressed: videoIds.isNotEmpty && !isLoading
              ? () => playerCubit.startPlayingPlaylist(videoIds)
              : null,
          isLoading: isLoading,
          isPrimary: true,
        ),
        EnhancedPrimaryActionButton(
          label: 'Add to Queue',
          icon: Icons.queue_music_rounded,
          onPressed: videoIds.isNotEmpty && !isLoading
              ? () => playerCubit.addAllToQueue(videoIds)
              : null,
          isPrimary: false,
        ),
      ],
    );
  }

  /// Creates a standard video action overflow menu
  List<OverflowMenuAction> buildVideoOverflowActions({
    required String videoId,
    required String videoTitle,
  }) {
    final playerCubit = read<PlayerCubit>();
    final downloadService = read<DownloadService>();
    final isInQueue = playerCubit.mtPlayerService.queue.value
        .map((e) => e.id)
        .contains(videoId);

    return [
      OverflowMenuAction(
        label: isInQueue ? 'Remove from Queue' : 'Add to Queue',
        icon: isInQueue ? Icons.remove : Icons.playlist_add,
        onTap: () {
          if (isInQueue) {
            playerCubit.removeFromQueue(videoId);
          } else {
            playerCubit.addToQueue(videoId);
          }
        },
      ),
      OverflowMenuAction(
        label: 'Download Video',
        icon: Icons.download,
        onTap: () {
          downloadService.download(
            videos: [
              {'id': videoId, 'title': videoTitle}
            ],
            context: this,
          );
        },
      ),
      OverflowMenuAction(
        label: 'Download Audio',
        icon: Icons.music_note,
        subtitle: 'Audio only',
        onTap: () {
          downloadService.download(
            videos: [
              {'id': videoId, 'title': videoTitle}
            ],
            context: this,
            isAudioOnly: true,
          );
        },
      ),
    ];
  }
}

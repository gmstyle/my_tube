import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';
import 'package:my_tube/utils/scroll_animations.dart';
import 'package:my_tube/utils/utils.dart';

class ChannelTile extends StatefulWidget {
  const ChannelTile({
    super.key,
    required this.channel,
    this.index = 0,
    this.enableScrollAnimation = false,
  });

  final models.ChannelTile channel;
  final int index;
  final bool enableScrollAnimation;

  @override
  State<ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<ChannelTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: AppAnimations.cardHover,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.cardHoverScale,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: AppAnimations.cardHoverCurve,
    ));

    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.hoverElevation,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: AppAnimations.cardHoverCurve,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = context.isCompact;

    Widget tileContent = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _elevationAnimation.value,
              shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
              surfaceTintColor: theme.colorScheme.surfaceTint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 12,
                vertical: 6,
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onHover: _onHoverChanged,
                  borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
                  splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  highlightColor:
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                  child: Padding(
                    padding: EdgeInsets.all(isCompact ? 12 : 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enhanced avatar with better styling
                        _buildEnhancedAvatar(context, isCompact),

                        SizedBox(width: isCompact ? 12 : 16),

                        // Enhanced content section with better typography
                        Expanded(
                          child: _buildEnhancedContent(context, isCompact),
                        ),

                        // Enhanced overflow menu for secondary actions
                        _buildEnhancedOverflowMenu(context, isCompact),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Apply scroll animation if enabled
    if (widget.enableScrollAnimation) {
      return ScrollVisibilityAnimator(
        animationType: ScrollAnimationType.fadeIn,
        child: tileContent,
      );
    }

    return tileContent;
  }

  Widget _buildEnhancedAvatar(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);
    final avatarSize = isCompact ? 56.0 : 72.0;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Utils.buildImageWithFallback(
          thumbnailUrl: widget.channel.thumbnailUrl,
          context: context,
          fit: BoxFit.cover,
          placeholder: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.person,
              size: avatarSize * 0.4,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedContent(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enhanced title with better typography hierarchy
        Text(
          widget.channel.title,
          style: theme.videoTitleStyle.copyWith(
            fontSize: isCompact ? 14 : 16,
            height: 1.3,
          ),
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),

        if (widget.channel.description != null &&
            widget.channel.description!.isNotEmpty) ...[
          SizedBox(height: isCompact ? 4 : 6),
          Text(
            widget.channel.description!,
            style: theme.videoSubtitleStyle.copyWith(
              fontSize: isCompact ? 12 : 13,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        if (widget.channel.subscriberCount != null) ...[
          SizedBox(height: isCompact ? 4 : 6),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: isCompact ? 14 : 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                _formatSubscriberCount(widget.channel.subscriberCount!),
                style: theme.videoSubtitleStyle.copyWith(
                  fontSize: isCompact ? 11 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEnhancedOverflowMenu(BuildContext context, bool isCompact) {
    final actions = _buildChannelOverflowActions(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        EnhancedOverflowMenu(
          actions: actions,
          icon: Icons.more_vert,
          tooltip: 'Channel options',
        ),
        // Add favorite button for quick access
        EnhancedFavoriteButton(
          entityId: widget.channel.id,
          entityType: FavoriteEntityType.channel,
          size: isCompact ? 20.0 : 24.0,
        ),
      ],
    );
  }

  List<OverflowMenuAction> _buildChannelOverflowActions(BuildContext context) {
    return [
      OverflowMenuAction(
        label: 'View Channel',
        icon: Icons.person,
        onTap: () {
          context.goNamed(AppRoute.channel.name,
              extra: {'channelId': widget.channel.id});
        },
      ),
      OverflowMenuAction(
        label: 'Share Channel',
        icon: Icons.share,
        onTap: () {
          // TODO: Implement channel sharing
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sharing ${widget.channel.title}...'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    ];
  }

  String _formatSubscriberCount(int count) {
    return '${Utils.formatNumber(count)} subscribers';
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/ui/views/common/material_interactive_components.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:my_tube/utils/scroll_animations.dart';
import 'package:my_tube/utils/utils.dart';

class ChannelTile extends StatelessWidget {
  const ChannelTile({
    super.key,
    required this.channel,
    this.index = 0,
    this.enableScrollAnimation = false,
    this.onTap,
  });

  final models.ChannelTile channel;
  final int index;
  final bool enableScrollAnimation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    Widget tileContent = MaterialHoverContainer(
      onTap: onTap ??
          () {
            context.goNamed(AppRoute.channel.name,
                extra: {'channelId': channel.id});
          },
      borderRadius: BorderRadius.circular(
          50), // Pill shape for channel list items looks modern
      fillColor: Colors.transparent,
      padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12, vertical: isCompact ? 8 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Avatar
          _buildAvatar(context, isCompact),

          SizedBox(width: isCompact ? 12 : 16),

          // Content
          Expanded(
            child: _buildContent(context, isCompact),
          ),

          // Actions
          _buildActions(context, isCompact),
        ],
      ),
    );

    if (enableScrollAnimation) {
      return ScrollVisibilityAnimator(
        animationType: ScrollAnimationType.fadeIn,
        child: tileContent,
      );
    }

    return tileContent;
  }

  Widget _buildAvatar(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);
    final size = isCompact ? 48.0 : 56.0;

    return ExpressiveImage(
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Utils.buildImageWithFallback(
            thumbnailUrl: channel.thumbnailUrl,
            context: context,
            fit: BoxFit.cover,
            placeholder: Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.person,
                size: size * 0.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          channel.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 14 : 16,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (channel.subscriberCount != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${Utils.formatNumber(channel.subscriberCount!)} subscribers',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: isCompact ? 12 : 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isCompact) {
    final actions = [
      OverflowMenuAction(
        label: 'View Channel',
        icon: Icons.account_box_outlined,
        onTap: () {
          context
              .goNamed(AppRoute.channel.name, extra: {'channelId': channel.id});
        },
      ),
      OverflowMenuAction(
        label: 'Share',
        icon: Icons.share,
        onTap: () {
          // Share logic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sharing ${channel.title}...'),
            ),
          );
        },
      ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnhancedOverflowMenu(
          actions: actions,
          icon: Icons.more_vert,
          tooltip: 'Channel options',
        ),
        SizedBox(width: isCompact ? 0 : 4),
        EnhancedFavoriteButton(
          entityId: channel.id,
          entityType: FavoriteEntityType.channel,
          size: isCompact ? 20.0 : 24.0,
        ),
      ],
    );
  }
}

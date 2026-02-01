import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Enhanced channel header component with modern Material 3 design
/// Features card-based layout, improved avatar presentation, and integrated actions
class EnhancedChannelHeader extends StatelessWidget {
  const EnhancedChannelHeader({
    super.key,
    required this.channel,
    required this.videoIds,
  });

  final Channel channel;
  final List<String> videoIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: _getResponsiveMargin(context),
      constraints: BoxConstraints(
        maxWidth: context.responsiveContentMaxWidth,
      ),
      child: context.themedCard(
        cardTheme: theme.headerCardTheme.copyWith(
          shape: _getResponsiveCardShape(context),
        ),
        child: Padding(
          padding: _getResponsiveContentPadding(context),
          child: _buildResponsiveLayout(context, theme),
        ),
      ),
    );
  }

  /// Responsive layout that adapts to different screen sizes
  Widget _buildResponsiveLayout(BuildContext context, ThemeData theme) {
    if (context.isLargeDesktop) {
      return _buildLargeDesktopLayout(context, theme);
    } else if (context.isDesktop || context.isTablet) {
      return _buildExpandedLayout(context, theme);
    } else {
      return _buildCompactLayout(context, theme);
    }
  }

  /// Large desktop layout with optimized space utilization
  Widget _buildLargeDesktopLayout(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(context, theme),
        SizedBox(width: _getResponsiveSpacing(context) * 1.5),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChannelInfo(context, theme),
              SizedBox(height: _getResponsiveSpacing(context)),
            ],
          ),
        ),
        SizedBox(width: _getResponsiveSpacing(context)),
        Expanded(
          flex: 1,
          child: _buildActionButtons(context, theme),
        ),
      ],
    );
  }

  /// Expanded layout for tablet and desktop
  Widget _buildExpandedLayout(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(context, theme),
        SizedBox(width: _getResponsiveSpacing(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChannelInfo(context, theme),
              SizedBox(height: _getResponsiveSpacing(context)),
              _buildActionButtons(context, theme),
            ],
          ),
        ),
      ],
    );
  }

  /// Compact layout for mobile devices
  Widget _buildCompactLayout(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildAvatar(context, theme),
        SizedBox(height: _getResponsiveSpacing(context)),
        _buildChannelInfo(context, theme),
        SizedBox(height: _getResponsiveSpacing(context)),
        _buildActionButtons(context, theme),
      ],
    );
  }

  /// Enhanced avatar with border, shadow and optimized dimensions
  Widget _buildAvatar(BuildContext context, ThemeData theme) {
    final avatarSize = AppBreakpoints.getChannelAvatarSize(context);

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: theme.enhancedAvatarDecoration,
      child: ClipOval(
        child: Utils.buildImageWithFallback(
          thumbnailUrl: channel.logoUrl,
          context: context,
          fit: BoxFit.cover,
          placeholder: Icon(
            Icons.person,
            size: avatarSize * 0.4,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// Channel information with improved hierarchy
  Widget _buildChannelInfo(BuildContext context, ThemeData theme) {
    final isCompact = context.isCompact;

    return Column(
      crossAxisAlignment:
          isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Channel name
        Text(
          channel.title,
          style: theme.headerTitleStyle,
          textAlign: isCompact ? TextAlign.center : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Subscriber count with proper formatting
        if (channel.subscribersCount != null)
          _buildSubscriberCount(context, theme, isCompact),
      ],
    );
  }

  /// Formatted subscriber count display
  Widget _buildSubscriberCount(
      BuildContext context, ThemeData theme, bool isCompact) {
    final formattedCount = _formatSubscriberCount(channel.subscribersCount!);

    return Row(
      mainAxisAlignment:
          isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Icon(
          Icons.people_outline,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          formattedCount,
          style: theme.statsTextStyle,
        ),
      ],
    );
  }

  /// Integrated action buttons with responsive styling
  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Container(
      padding: _getResponsiveActionPadding(context),
      decoration: theme.actionGroupDecoration,
      child: _buildResponsiveActions(context, theme),
    );
  }

  /// Responsive action layout based on screen size
  Widget _buildResponsiveActions(BuildContext context, ThemeData theme) {
    if (context.isLargeDesktop) {
      return _buildLargeDesktopActions(context, theme);
    } else if (context.isExpanded) {
      return _buildExpandedActions(context, theme);
    } else {
      return _buildCompactActions(context, theme);
    }
  }

  /// Large desktop action layout with more space
  Widget _buildLargeDesktopActions(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPlayAllButton(context, theme),
        SizedBox(height: _getResponsiveSpacing(context) * 0.5),
        _buildQueueButton(context, theme),
      ],
    );
  }

  /// Expanded action layout for tablet/desktop
  Widget _buildExpandedActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        _buildPlayAllButton(context, theme),
        SizedBox(width: _getResponsiveSpacing(context)),
        _buildQueueButton(context, theme),
        const Spacer(),
      ],
    );
  }

  /// Compact action layout for mobile
  Widget _buildCompactActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(child: _buildPlayAllButton(context, theme)),
        SizedBox(width: _getResponsiveSpacing(context)),
        Expanded(child: _buildQueueButton(context, theme)),
      ],
    );
  }

  /// Play all videos button
  Widget _buildPlayAllButton(BuildContext context, ThemeData theme) {
    final playerCubit = context.read<PlayerCubit>();

    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final isPlayLoading = state.status == PlayerStatus.loading &&
            state.loadingOperation == LoadingOperation.play;

        final progressText = (isPlayLoading &&
                state.loadingProgress != null &&
                state.loadingTotal != null)
            ? '${state.loadingProgress}/${state.loadingTotal}'
            : null;

        return EnhancedPrimaryActionButton(
          label: progressText ?? 'Play All',
          icon: Icons.play_arrow,
          onPressed: videoIds.isNotEmpty && state.status != PlayerStatus.loading
              ? () => playerCubit.startPlayingPlaylist(videoIds)
              : null,
          isLoading: isPlayLoading,
          isPrimary: true,
        );
      },
    );
  }

  /// Add to queue button
  Widget _buildQueueButton(BuildContext context, ThemeData theme) {
    final playerCubit = context.read<PlayerCubit>();

    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final isAddToQueueLoading = state.status == PlayerStatus.loading &&
            state.loadingOperation == LoadingOperation.addToQueue;

        final progressText = (isAddToQueueLoading &&
                state.loadingProgress != null &&
                state.loadingTotal != null)
            ? '${state.loadingProgress}/${state.loadingTotal}'
            : null;

        return EnhancedPrimaryActionButton(
          label: progressText ?? 'Add to Queue',
          icon: Icons.queue_music,
          onPressed: videoIds.isNotEmpty && state.status != PlayerStatus.loading
              ? () => playerCubit.addAllToQueue(videoIds)
              : null,
          isLoading: isAddToQueueLoading,
          isPrimary: false,
        );
      },
    );
  }

  /// Format subscriber count with proper number formatting
  String _formatSubscriberCount(int count) {
    final formatted = Utils.formatNumber(count);
    return '$formatted subscribers';
  }

  // Responsive Design Helper Methods

  /// Get responsive margin based on screen size
  EdgeInsets _getResponsiveMargin(BuildContext context) {
    return context.selectByBreakpoint(
      mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      desktop: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      largeDesktop: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    );
  }

  /// Get responsive card shape based on screen size
  RoundedRectangleBorder _getResponsiveCardShape(BuildContext context) {
    final radius = context.selectByBreakpoint(
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
      largeDesktop: 24.0,
    );
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Get responsive content padding
  EdgeInsets _getResponsiveContentPadding(BuildContext context) {
    return context.selectByBreakpoint(
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(20),
      desktop: const EdgeInsets.all(24),
      largeDesktop: const EdgeInsets.all(28),
    );
  }

  /// Get responsive action button padding
  EdgeInsets _getResponsiveActionPadding(BuildContext context) {
    return context.selectByBreakpoint(
      mobile: const EdgeInsets.all(12),
      tablet: const EdgeInsets.all(14),
      desktop: const EdgeInsets.all(16),
      largeDesktop: const EdgeInsets.all(18),
    );
  }

  /// Get responsive spacing between elements
  double _getResponsiveSpacing(BuildContext context) {
    return context.selectByBreakpoint(
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
      largeDesktop: 24.0,
    );
  }
}

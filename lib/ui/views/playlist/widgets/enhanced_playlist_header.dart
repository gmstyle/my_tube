import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/ui/views/common/enhanced_action_buttons.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:my_tube/utils/app_theme_extensions.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Enhanced playlist header component with modern Material 3 design
/// Features card-based layout, improved image presentation, and better action buttons
class EnhancedPlaylistHeader extends StatefulWidget {
  const EnhancedPlaylistHeader({
    super.key,
    required this.playlist,
    required this.videoIds,
    this.thumbnailUrl,
  });

  final Playlist playlist;
  final List<String> videoIds;
  final String? thumbnailUrl;

  @override
  State<EnhancedPlaylistHeader> createState() => _EnhancedPlaylistHeaderState();
}

class _EnhancedPlaylistHeaderState extends State<EnhancedPlaylistHeader>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final miniplayerCubit = context.read<PlayerCubit>();
    final playlistState = context.watch<PlaylistBloc>().state;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildHeaderContent(
                context, theme, miniplayerCubit, playlistState),
          ),
        );
      },
    );
  }

  Widget _buildHeaderContent(
    BuildContext context,
    ThemeData theme,
    PlayerCubit miniplayerCubit,
    PlaylistState playlistState,
  ) {
    return Container(
      margin: _getResponsiveMargin(context),
      constraints: BoxConstraints(
        maxWidth: context.responsiveContentMaxWidth,
      ),
      child: Card(
        elevation: theme.headerCardTheme.elevation,
        shadowColor: theme.headerCardTheme.shadowColor,
        surfaceTintColor: theme.headerCardTheme.surfaceTintColor,
        shape: _getResponsiveCardShape(context),
        clipBehavior: Clip.antiAlias,
        child: _buildResponsiveLayout(
            context, theme, miniplayerCubit, playlistState),
      ),
    );
  }

  /// Responsive layout that adapts to different screen sizes
  Widget _buildResponsiveLayout(
    BuildContext context,
    ThemeData theme,
    PlayerCubit miniplayerCubit,
    PlaylistState playlistState,
  ) {
    if (context.isLargeDesktop) {
      return _buildLargeDesktopLayout(
          context, theme, miniplayerCubit, playlistState);
    } else if (context.isDesktop || context.isTablet) {
      return _buildSideBySideLayout(
          context, theme, miniplayerCubit, playlistState);
    } else {
      return _buildStackedLayout(
          context, theme, miniplayerCubit, playlistState);
    }
  }

  /// Large desktop layout with optimized space utilization
  Widget _buildLargeDesktopLayout(
    BuildContext context,
    ThemeData theme,
    PlayerCubit miniplayerCubit,
    PlaylistState playlistState,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image section - smaller on large screens
          Expanded(
            flex: 3,
            child: _buildImageSection(context, theme),
          ),
          // Content section - larger on large screens
          Expanded(
            flex: 5,
            child: _buildContentSection(
                context, theme, miniplayerCubit, playlistState),
          ),
        ],
      ),
    );
  }

  /// Side-by-side layout for tablet and desktop
  Widget _buildSideBySideLayout(
    BuildContext context,
    ThemeData theme,
    PlayerCubit miniplayerCubit,
    PlaylistState playlistState,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image section
          Expanded(
            flex: context.isTablet ? 3 : 2,
            child: _buildImageSection(context, theme),
          ),
          // Content section
          Expanded(
            flex: context.isTablet ? 4 : 3,
            child: _buildContentSection(
                context, theme, miniplayerCubit, playlistState),
          ),
        ],
      ),
    );
  }

  /// Stacked layout for mobile devices
  Widget _buildStackedLayout(
    BuildContext context,
    ThemeData theme,
    PlayerCubit miniplayerCubit,
    PlaylistState playlistState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image section with mobile-optimized aspect ratio
        _buildImageSection(context, theme),
        // Content section with mobile-optimized padding
        _buildContentSection(context, theme, miniplayerCubit, playlistState),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context, ThemeData theme) {
    final aspectRatio = _getResponsiveAspectRatio(context);

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail image
          Utils.buildImageWithFallback(
            thumbnailUrl:
                widget.thumbnailUrl ?? widget.playlist.thumbnails.highResUrl,
            context: context,
            fit: BoxFit.cover,
          ),
          // Enhanced gradient overlay
          Container(
            decoration: _buildGradientOverlay(theme),
          ),
          // Overlay content (video count indicator) with responsive positioning
          Positioned(
            top: _getResponsiveBadgePosition(context),
            right: _getResponsiveBadgePosition(context),
            child: _buildVideoCountBadge(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    ThemeData theme,
    PlayerCubit miniplayerCubit,
    PlaylistState playlistState,
  ) {
    return Padding(
      padding: _getResponsiveContentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and metadata
          _buildTitleSection(context, theme),
          SizedBox(height: _getResponsiveSpacing(context)),
          // Action buttons
          _buildActionButtons(context, theme, miniplayerCubit, playlistState),
          SizedBox(height: _getResponsiveSpacing(context) * 0.5),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Playlist title
        Text(
          widget.playlist.title,
          style: theme.headerTitleStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Metadata row
        _buildMetadataRow(context, theme),
        // Description if available
        if (widget.playlist.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDescription(context, theme),
        ],
      ],
    );
  }

  Widget _buildMetadataRow(BuildContext context, ThemeData theme) {
    final isCompact = context.isCompact;
    final iconSize = isCompact ? 18.0 : 20.0;
    final spacing = isCompact ? 6.0 : 8.0;

    if (isCompact && widget.playlist.author.isNotEmpty) {
      // Stack metadata vertically on small screens
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.playlist_play_rounded,
                size: iconSize,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: spacing),
              Text(
                _getFormattedVideoCount(),
                style: theme.statsTextStyle.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                size: iconSize - 2,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: spacing),
              Flexible(
                child: Text(
                  widget.playlist.author,
                  style: theme.headerSubtitleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Horizontal layout for larger screens
    return Row(
      children: [
        Icon(
          Icons.playlist_play_rounded,
          size: iconSize,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: spacing),
        Text(
          _getFormattedVideoCount(),
          style: theme.statsTextStyle.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.playlist.author.isNotEmpty) ...[
          SizedBox(width: isCompact ? 12 : 16),
          Icon(
            Icons.person_rounded,
            size: iconSize - 2,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: spacing),
          Flexible(
            child: Text(
              widget.playlist.author,
              style: theme.headerSubtitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(BuildContext context, ThemeData theme) {
    return Text(
      widget.playlist.description,
      style: theme.headerSubtitleStyle,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    PlayerCubit miniplayerCubit,
    PlaylistState playlistState,
  ) {
    final isLoading = playlistState.status == PlaylistStatus.loading;

    return context.buildPlayQueueActions(
      videoIds: widget.videoIds,
      isLoading: isLoading,
    );
  }

  Widget _buildVideoCountBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.playlist_play_rounded,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            widget.playlist.videoCount.toString(),
            style: theme.statsTextStyle.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildGradientOverlay(ThemeData theme) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.transparent,
          theme.colorScheme.surface.withValues(alpha: 0.1),
          theme.colorScheme.surface.withValues(alpha: 0.3),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ),
    );
  }

  String _getFormattedVideoCount() {
    final count = widget.playlist.videoCount;
    if (count == 1) {
      return '1 video';
    }
    return '$count videos';
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

  /// Get responsive aspect ratio for playlist thumbnail
  double _getResponsiveAspectRatio(BuildContext context) {
    return context.selectByBreakpoint(
      mobile: 16 / 9, // Standard video aspect ratio
      tablet: 16 / 9,
      desktop: 16 / 9,
      largeDesktop: 16 / 9,
    );
  }

  /// Get responsive badge positioning
  double _getResponsiveBadgePosition(BuildContext context) {
    return context.selectByBreakpoint(
      mobile: 12.0,
      tablet: 16.0,
      desktop: 16.0,
      largeDesktop: 20.0,
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

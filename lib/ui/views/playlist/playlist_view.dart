import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/shared/responsive_layout_builder.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/ui/views/playlist/layouts/playlist_mobile_layout.dart';
import 'package:my_tube/ui/views/playlist/layouts/playlist_tablet_layout.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key, required this.playlistId});

  final String playlistId;

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  PersistentUiCubit? _uiCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _uiCubit ??= context.read<PersistentUiCubit>();
  }

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlaylistState state) {
    switch (state.status) {
      case PlaylistStatus.loading:
        return _buildLoadingState(context);

      case PlaylistStatus.loaded:
        return _buildLoadedState(context, state);

      case PlaylistStatus.failure:
        return _buildErrorState(context, state);

      default:
        return _buildLoadingState(context);
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    return const CustomSkeletonPlaylist();
  }

  Widget _buildLoadedState(BuildContext context, PlaylistState state) {
    final playlist = state.response!['playlist'] as Playlist;
    final videos = state.response!['videos'] as List<models.VideoTile>;
    final videoIds = videos.map((v) => v.id).toList();
    final thumbnailUrl = state.response!['thumbnailUrl'] as String?;
    final effectiveThumbnail = thumbnailUrl ?? playlist.thumbnails.highResUrl;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_staggerController.isAnimating) {
        _staggerController.reset();
        _staggerController.forward();
      }
    });

    return ResponsiveLayoutBuilder(
      mobile: (_) => PlaylistMobileLayout(
        playlistId: widget.playlistId,
        playlist: playlist,
        videos: videos,
        videoIds: videoIds,
        thumbnailUrl: effectiveThumbnail,
        state: state,
        staggerController: _staggerController,
      ),
      tablet: (_) => PlaylistTabletLayout(
        playlistId: widget.playlistId,
        playlist: playlist,
        videos: videos,
        videoIds: videoIds,
        thumbnailUrl: effectiveThumbnail,
        state: state,
        staggerController: _staggerController,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, PlaylistState state) {
    // Determine error type based on error message with consistent pattern
    final errorMessage = state.error ??
        'An unexpected error occurred while loading the playlist.';
    final lowerMessage = errorMessage.toLowerCase();

    // Network-related errors
    if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('timeout') ||
        lowerMessage.contains('unreachable')) {
      return NetworkErrorState(
        onRetry: () {
          context.read<PlaylistBloc>().add(
                GetPlaylist(playlistId: widget.playlistId),
              );
        },
        onGoBack: () => Navigator.of(context).pop(),
      );
    }

    // Content not found errors
    if (lowerMessage.contains('not found') ||
        lowerMessage.contains('404') ||
        lowerMessage.contains('unavailable') ||
        lowerMessage.contains('deleted')) {
      return ContentNotFoundState(
        onRetry: () {
          context.read<PlaylistBloc>().add(
                GetPlaylist(playlistId: widget.playlistId),
              );
        },
        onGoBack: () => Navigator.of(context).pop(),
      );
    }

    // Server-related errors
    if (lowerMessage.contains('server') ||
        lowerMessage.contains('500') ||
        lowerMessage.contains('503') ||
        lowerMessage.contains('502')) {
      return ServerErrorState(
        onRetry: () {
          context.read<PlaylistBloc>().add(
                GetPlaylist(playlistId: widget.playlistId),
              );
        },
        onGoBack: () => Navigator.of(context).pop(),
      );
    }

    // Generic error state with consistent styling
    return EnhancedErrorState(
      title: 'Unable to Load Playlist',
      message: errorMessage,
      onRetry: () {
        context.read<PlaylistBloc>().add(
              GetPlaylist(playlistId: widget.playlistId),
            );
      },
      onGoBack: () => Navigator.of(context).pop(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/ui/shared/responsive_layout_builder.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/channel/layouts/channel_mobile_layout.dart';
import 'package:my_tube/ui/views/channel/layouts/channel_tablet_layout.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/utils/app_animations.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ChannelView extends StatefulWidget {
  const ChannelView({super.key, required this.channelId});

  final String channelId;

  @override
  State<ChannelView> createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView>
    with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final TabController _tabController;
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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final bloc = context.read<ChannelPageBloc>();
    final state = bloc.state;
    if (state.status != ChannelPageStatus.loaded) return;
    final channel = state.data?['channel'] as Channel?;
    if (channel == null) return;

    switch (_tabController.index) {
      case 1:
        // Lazy-load playlists on first visit
        if (state.playlists == null && !state.isLoadingPlaylists) {
          bloc.add(LoadChannelPlaylists(channelTitle: channel.title));
        }
      case 2:
        // Lazy-load shorts on first visit
        if (state.shorts == null && !state.isLoadingShorts) {
          bloc.add(LoadChannelShorts(channelId: channel.id.value));
        }
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ChannelPageBloc, ChannelPageState>(
        builder: (context, state) {
          return _buildStateContent(context, state);
        },
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, ChannelPageState state) {
    switch (state.status) {
      case ChannelPageStatus.loading:
        return _buildEnhancedLoadingState(context);

      case ChannelPageStatus.loaded:
        return _buildLoadedContent(context, state);

      case ChannelPageStatus.failure:
        return _buildEnhancedErrorState(context, state);

      default:
        return _buildEnhancedLoadingState(context);
    }
  }

  /// Enhanced loading state with improved skeleton
  Widget _buildEnhancedLoadingState(BuildContext context) {
    return const CustomSkeletonChannel();
  }

  /// Enhanced error state with recovery actions and consistent pattern
  Widget _buildEnhancedErrorState(
      BuildContext context, ChannelPageState state) {
    final errorMessage = state.error ??
        'An unexpected error occurred while loading the channel.';
    final lowerMessage = errorMessage.toLowerCase();

    // Network-related errors
    if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('timeout') ||
        lowerMessage.contains('unreachable')) {
      return NetworkErrorState(
        onRetry: () {
          context.read<ChannelPageBloc>().add(
                GetChannelDetails(channelId: widget.channelId),
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
          context.read<ChannelPageBloc>().add(
                GetChannelDetails(channelId: widget.channelId),
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
          context.read<ChannelPageBloc>().add(
                GetChannelDetails(channelId: widget.channelId),
              );
        },
        onGoBack: () => Navigator.of(context).pop(),
      );
    }

    return EnhancedErrorState(
      title: 'Failed to Load Channel',
      message: errorMessage,
      onRetry: () {
        context.read<ChannelPageBloc>().add(
              GetChannelDetails(channelId: widget.channelId),
            );
      },
      onGoBack: () => Navigator.of(context).pop(),
    );
  }

  /// Main loaded content — delegates to layout widgets via [ResponsiveLayoutBuilder].
  Widget _buildLoadedContent(BuildContext context, ChannelPageState state) {
    final channel = state.data?['channel'] as Channel;
    final rawItems = state.items;
    final videos = rawItems != null
        ? List<models.VideoTile>.from(
            rawItems.map((e) => e as models.VideoTile))
        : <models.VideoTile>[];
    final ids = videos.map((v) => v.id).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_staggerController.isAnimating) {
        _staggerController.reset();
        _staggerController.forward();
      }
    });

    return ResponsiveLayoutBuilder(
      mobile: (_) => ChannelMobileLayout(
        channelId: widget.channelId,
        channel: channel,
        videos: videos,
        ids: ids,
        state: state,
        staggerController: _staggerController,
        tabController: _tabController,
      ),
      tablet: (_) => ChannelTabletLayout(
        channelId: widget.channelId,
        channel: channel,
        videos: videos,
        ids: ids,
        state: state,
        staggerController: _staggerController,
        tabController: _tabController,
      ),
    );
  }
}
// ─── end of channel_view.dart ─────────────────────────────────────────────────
// (helpers and _TabBarDelegate moved to layout files)

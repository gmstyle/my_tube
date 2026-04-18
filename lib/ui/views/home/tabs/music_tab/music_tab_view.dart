import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/music_tab/music_tab_bloc.dart';
import 'package:my_tube/ui/shared/responsive_layout_builder.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/enhanced_error_states.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/layouts/music_layouts.dart';
import 'package:my_tube/utils/constants.dart';

class MusicTabView extends StatefulWidget {
  const MusicTabView({super.key});

  @override
  State<MusicTabView> createState() => _MusicTabViewState();
}

class _MusicTabViewState extends State<MusicTabView> {
  // NOTE: dispatch is already sent by MusicTabPage; initState is intentionally
  // left without an additional add() to avoid a double fetch.

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicTabBloc, MusicTabState>(
      builder: (context, state) {
        // ── Loading ──────────────────────────────────────────────────────
        if (state.status == MusicTabStatus.loading) {
          return const CustomSkeletonMusicHome();
        }

        // ── Error ────────────────────────────────────────────────────────
        if (state.status == MusicTabStatus.error) {
          return EnhancedErrorState(
            icon: Icons.music_off_outlined,
            title: musicLoadErrorTitle,
            message: state.error ?? musicLoadErrorMessage,
            showBackButton: false,
            onRetry: () =>
                context.read<MusicTabBloc>().add(const GetMusicTabContent()),
          );
        }

        // ── Success ──────────────────────────────────────────────────────
        if (state.status == MusicTabStatus.success) {
          return ResponsiveLayoutBuilder(
            mobile: (_) => MusicMobileLayout(state: state),
            tablet: (_) => MusicTabletLayout(state: state),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

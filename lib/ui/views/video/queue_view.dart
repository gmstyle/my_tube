import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/clear_queue_button.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/media_item_list.dart';
import 'package:my_tube/utils/constants.dart';

class QueueView extends StatefulWidget {
  const QueueView({
    super.key,
    this.showMiniPlayer = true,
    this.hideMiniPlayerOnDispose = false,
  });
  final bool showMiniPlayer;
  final bool hideMiniPlayerOnDispose;

  @override
  State<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  late final PersistentUiCubit persistentUiCubit;
  late final PlayerCubit playerCubit;

  bool _queueIsEmpty = false;
  bool _isFistRoutePopped = false;

  @override
  void initState() {
    super.initState();
    persistentUiCubit = context.read<PersistentUiCubit>();
    playerCubit = context.read<PlayerCubit>();
    if (mounted) {
      persistentUiCubit.setHasNavBar(false);
      // Mostra mini player in queue view (a meno che non sia esplicitamente nascosto)
      if (widget.showMiniPlayer) {
        persistentUiCubit.setPlayerVisibility(true);
      }
    }

    // Ascolta quando la queue diventa vuota (dopo rimozione ultimo video)
    playerCubit.mtPlayerService.queue.listen((queue) {
      if (queue.isEmpty && mounted) {
        setState(() {
          _queueIsEmpty = true;
        });
        // Torna alla rotta root quando la queue è vuota
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).popUntil((route) {
              if (route.isFirst) _isFistRoutePopped = true;
              persistentUiCubit.setPlayerVisibility(true);
              persistentUiCubit.setHasNavBar(true);
              return _isFistRoutePopped;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    if (widget.hideMiniPlayerOnDispose && !_isFistRoutePopped) {
      persistentUiCubit.setPlayerVisibility(false);
    }
    persistentUiCubit.setHasNavBar(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
        title: const Text('Queue'),
        centerTitle: true,
        actions: const [ClearQueueButton()],
      ),
      body: Column(
        children: [
          Expanded(child: const MediaItemList()),
          const SizedBox(height: miniPlayerHeight)
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/views/channel/widgets/channel_header.dart';
import 'package:my_tube/ui/views/common/resource_tile.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelPageBloc, ChannelPageState>(
      builder: (context, state) {
        switch (state.status) {
          case ChannelPageStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case ChannelPageStatus.loaded:
            final channel = state.channel;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    ChannelHeader(channel: channel),
                    const SizedBox(height: 16),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: channel?.videos!.length,
                        itemBuilder: (context, index) {
                          final video = state.channel?.videos![index];
                          return GestureDetector(
                            onTap: () async {
                              await context
                                  .read<MiniPlayerCubit>()
                                  .startPlaying(video);
                            },
                            child: ResourceTile(resource: video!),
                          );
                        }),
                  ],
                ),
              ),
            );

          case ChannelPageStatus.failure:
            return Center(
              child: Text(state.error!),
            );

          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

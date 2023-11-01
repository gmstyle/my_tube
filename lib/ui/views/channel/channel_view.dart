import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/channel_page/bloc/channel_page_bloc.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.arrow_back)),
              const Text('Channel'),
            ],
          ),
          BlocBuilder<ChannelPageBloc, ChannelPageState>(
            builder: (context, state) {
              return Center(
                child: Text(
                    'Channel: ${state.channel?.videos?.first.id ?? 'No videos'}'),
              );
            },
          ),
        ],
      ),
    );
  }
}

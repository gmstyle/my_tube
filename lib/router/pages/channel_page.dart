import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/ui/views/channel/channel_view.dart';

class ChannelPage extends Page {
  const ChannelPage({super.key, required this.channelId});

  final String channelId;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => MultiBlocProvider(providers: [
        BlocProvider<ChannelPageBloc>(
            create: (context) => ChannelPageBloc(
                innertubeRepository: context.read<InnertubeRepository>())
              ..add(GetChannelDetails(channelId: channelId)))
      ], child: ChannelView(channelId: channelId)),
    );
  }
}

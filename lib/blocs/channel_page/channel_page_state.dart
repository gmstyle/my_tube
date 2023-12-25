part of 'channel_page_bloc.dart';

enum ChannelPageStatus { initial, loading, loaded, failure }

class ChannelPageState extends Equatable {
  const ChannelPageState._({required this.status, this.channel, this.error});

  final ChannelPageStatus status;
  final ChannelPageMT? channel;
  final String? error;

  const ChannelPageState.initial() : this._(status: ChannelPageStatus.initial);
  const ChannelPageState.loading() : this._(status: ChannelPageStatus.loading);
  const ChannelPageState.loaded(ChannelPageMT channel)
      : this._(status: ChannelPageStatus.loaded, channel: channel);
  const ChannelPageState.failure({required String error})
      : this._(status: ChannelPageStatus.failure, error: error);

  @override
  List<Object?> get props => [status, channel, error];
}

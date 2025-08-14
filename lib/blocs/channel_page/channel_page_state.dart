part of 'channel_page_bloc.dart';

enum ChannelPageStatus { initial, loading, loaded, failure }

class ChannelPageState extends Equatable {
  const ChannelPageState._({required this.status, this.data, this.error});

  final ChannelPageStatus status;
  final Map<String, dynamic>? data;
  final String? error;

  const ChannelPageState.initial() : this._(status: ChannelPageStatus.initial);
  const ChannelPageState.loading() : this._(status: ChannelPageStatus.loading);
  const ChannelPageState.loaded(Map<String, dynamic> data)
      : this._(status: ChannelPageStatus.loaded, data: data);
  const ChannelPageState.failure({required String error})
      : this._(status: ChannelPageStatus.failure, error: error);

  @override
  List<Object?> get props => [status, data, error];
}

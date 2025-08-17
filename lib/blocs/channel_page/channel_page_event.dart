part of 'channel_page_bloc.dart';

sealed class ChannelPageEvent extends Equatable {
  const ChannelPageEvent();

  @override
  List<Object> get props => [];
}

class GetChannelDetails extends ChannelPageEvent {
  const GetChannelDetails({required this.channelId});

  final String channelId;

  @override
  List<Object> get props => [channelId];
}

class LoadMoreChannelVideos extends ChannelPageEvent {
  const LoadMoreChannelVideos();

  @override
  List<Object> get props => [];
}

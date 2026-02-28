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

class LoadChannelShorts extends ChannelPageEvent {
  const LoadChannelShorts({required this.channelId});

  final String channelId;

  @override
  List<Object> get props => [channelId];
}

class LoadMoreChannelShorts extends ChannelPageEvent {
  const LoadMoreChannelShorts();

  @override
  List<Object> get props => [];
}

class LoadChannelPlaylists extends ChannelPageEvent {
  const LoadChannelPlaylists({required this.channelTitle});

  final String channelTitle;

  @override
  List<Object> get props => [channelTitle];
}

class LoadMoreChannelPlaylists extends ChannelPageEvent {
  const LoadMoreChannelPlaylists();

  @override
  List<Object> get props => [];
}

part of 'channel_page_bloc.dart';

enum ChannelPageStatus { initial, loading, loaded, failure }

class ChannelPageState extends Equatable {
  const ChannelPageState._({
    required this.status,
    this.data,
    this.items,
    this.uploadsList,
    this.isLoadingMore = false,
    this.error,
  });

  final ChannelPageStatus status;
  final Map<String, dynamic>? data; // original channel metadata
  final List<dynamic>? items; // accumulated video tiles
  final Object? uploadsList; // opaque ChannelUploadsList
  final bool isLoadingMore;
  final String? error;

  const ChannelPageState.initial() : this._(status: ChannelPageStatus.initial);
  const ChannelPageState.loading() : this._(status: ChannelPageStatus.loading);
  const ChannelPageState.loaded(Map<String, dynamic> data,
      {List<dynamic>? items, Object? uploadsList})
      : this._(
            status: ChannelPageStatus.loaded,
            data: data,
            items: items,
            uploadsList: uploadsList);
  const ChannelPageState.failure({required String error})
      : this._(status: ChannelPageStatus.failure, error: error);

  ChannelPageState copyWith({
    ChannelPageStatus? status,
    Map<String, dynamic>? data,
    List<dynamic>? items,
    Object? uploadsList,
    bool? isLoadingMore,
    String? error,
  }) {
    return ChannelPageState._(
      status: status ?? this.status,
      data: data ?? this.data,
      items: items ?? this.items,
      uploadsList: uploadsList ?? this.uploadsList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, data, items, uploadsList, isLoadingMore, error];
}

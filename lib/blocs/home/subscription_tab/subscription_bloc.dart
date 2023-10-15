import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/respositories/youtube_repository.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final YoutubeRepository youtubeRepository;
  final Box settingsBox = Hive.box('settings');

  SubscriptionBloc({required this.youtubeRepository})
      : super(const SubscriptionState.loading()) {
    on<GetSubscriptions>((event, emit) async {
      await _onGetSubscriptions(event, emit);
    });

    on<GetNextPageSubscriptions>((event, emit) async {
      await _onGetNextPageSubscriptions(event, emit);
    });
  }

  Future<void> _onGetSubscriptions(
      GetSubscriptions event, Emitter<SubscriptionState> emit) async {
    emit(const SubscriptionState.loading());
    try {
      final response = await youtubeRepository.getSubscribedChannels();
      log('1 nextPageToken: ${response.nextPageToken}');
      emit(SubscriptionState.loaded(response: response));
    } catch (error) {
      emit(SubscriptionState.error(error: error.toString()));
    }
  }

  Future<void> _onGetNextPageSubscriptions(
      GetNextPageSubscriptions event, Emitter<SubscriptionState> emit) async {
    try {
      final List<VideoMT> videos = state.status == SubscriptionStatus.loaded
          ? state.response!.videos
          : const <VideoMT>[];
      final response = await youtubeRepository.getSubscribedChannels(
          nextPageToken: event.nextPageToken);

      final newVideos = response.videos;

      final updatedVideos = [...videos, ...newVideos];
      emit(SubscriptionState.loaded(
          response: VideoResponseMT(
              videos: updatedVideos, nextPageToken: response.nextPageToken)));
    } catch (error) {
      emit(SubscriptionState.error(error: error.toString()));
    }
  }
}
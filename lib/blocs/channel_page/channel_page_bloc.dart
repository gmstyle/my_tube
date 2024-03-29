import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/channel_page_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';

part 'channel_page_event.dart';
part 'channel_page_state.dart';

class ChannelPageBloc extends Bloc<ChannelPageEvent, ChannelPageState> {
  final InnertubeRepository innertubeRepository;

  ChannelPageBloc({required this.innertubeRepository})
      : super(const ChannelPageState.initial()) {
    on<GetChannelDetails>((event, emit) async {
      await _onGetChannelDetails(event, emit);
    });
  }

  Future<void> _onGetChannelDetails(
      GetChannelDetails event, Emitter<ChannelPageState> emit) async {
    emit(const ChannelPageState.loading());
    try {
      final channelDetails =
          await innertubeRepository.getChannel(event.channelId);
      emit(ChannelPageState.loaded(channelDetails));
    } catch (e) {
      emit(const ChannelPageState.failure(error: 'Failed to load channel'));
    }
  }
}

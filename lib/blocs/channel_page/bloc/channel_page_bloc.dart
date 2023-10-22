import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'channel_page_event.dart';
part 'channel_page_state.dart';

class ChannelPageBloc extends Bloc<ChannelPageEvent, ChannelPageState> {
  ChannelPageBloc() : super(ChannelPageInitial()) {
    on<ChannelPageEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

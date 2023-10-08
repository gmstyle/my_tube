import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc() : super(const SubscriptionState.initial()) {
    on<SubscriptionEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

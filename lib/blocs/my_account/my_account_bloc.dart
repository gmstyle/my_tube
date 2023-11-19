import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/respositories/youtube_repository.dart';

part 'my_account_event.dart';
part 'my_account_state.dart';

class MyAccountBloc extends Bloc<MyAccountEvent, MyAccountState> {
  final YoutubeRepository youtubeRepository;

  MyAccountBloc({
    required this.youtubeRepository,
  }) : super(const MyAccountState.initial()) {
    on<MyAccountEvent>((event, emit) async {});
  }
}

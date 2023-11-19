import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/queue_repository.dart';
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

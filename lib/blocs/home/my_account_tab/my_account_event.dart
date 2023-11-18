part of 'my_account_bloc.dart';

sealed class MyAccountEvent extends Equatable {
  const MyAccountEvent();

  @override
  List<Object> get props => [];
}

class GetQueue extends MyAccountEvent {}

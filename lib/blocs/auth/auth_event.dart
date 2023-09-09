part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignIn extends AuthEvent {
  const SignIn();

  @override
  List<Object> get props => [];
}

class SignOut extends AuthEvent {
  const SignOut();

  @override
  List<Object> get props => [];
}

class GetCurrentUser extends AuthEvent {
  const GetCurrentUser();

  @override
  List<Object> get props => [];
}

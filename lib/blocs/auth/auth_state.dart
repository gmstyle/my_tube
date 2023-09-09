part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final GoogleSignInAccount? user;
  final String? error;

  const AuthState.unknown()
      : this._(status: AuthStatus.unknown, user: null, error: null);
  const AuthState.authenticated({required GoogleSignInAccount user})
      : this._(status: AuthStatus.authenticated);
  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user, error];
}

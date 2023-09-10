import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../respositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc({required this.authRepository}) : super(const AuthState.unknown()) {
    on<SignIn>((event, emit) async {
      await _onSignIn(event, emit);
    });

    on<SignOut>((event, emit) async {
      await _onSignOut(event, emit);
    });

    on<CheckIfIsLoggedIn>((event, emit) async {
      await _onCheckIfIsLoggedIn(event, emit);
    });
  }

  Future<void> _onSignIn(SignIn event, Emitter<AuthState> emit) async {
    emit(const AuthState.unknown());
    try {
      final response = await authRepository.signIn();
      if (response != null) {
        emit(AuthState.authenticated(user: response));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(const AuthState.unknown());
    try {
      await authRepository.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onCheckIfIsLoggedIn(
      CheckIfIsLoggedIn event, Emitter<AuthState> emit) async {
    emit(const AuthState.unknown());
    try {
      final isLoggedIn = await authRepository.isLogged();
      if (isLoggedIn) {
        final response = await authRepository.signInSilently();
        if (response != null) {
          emit(AuthState.authenticated(user: response));
        } else {
          emit(const AuthState.unauthenticated());
        }
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }
}

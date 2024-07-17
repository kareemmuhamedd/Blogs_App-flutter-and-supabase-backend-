part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess(
    this.user,
  );
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({
    required this.message,
  });
}

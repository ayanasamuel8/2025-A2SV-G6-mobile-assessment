part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class LoggedinState extends AuthState {
  const LoggedinState();

  @override
  List<Object> get props => [];
}

class SignedupState extends AuthState {
  const SignedupState();

  @override
  List<Object> get props => [];
}

class LoggedoutState extends AuthState {
  const LoggedoutState();

  @override
  List<Object> get props => [];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthenticatedState extends AuthState {
  const AuthenticatedState();

  @override
  List<Object> get props => [];
}

class UnAuthenticatedState extends AuthState {
  const UnAuthenticatedState();

  @override
  List<Object> get props => [];
}

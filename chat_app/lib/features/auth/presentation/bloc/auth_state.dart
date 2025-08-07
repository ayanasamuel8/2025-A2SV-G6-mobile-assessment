part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class LoginState extends AuthState {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoggedinState extends LoginState {
  const LoggedinState();

  @override
  List<Object> get props => [];
}

class LoginFailedState extends LoginState {
  const LoginFailedState(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

class LoginLoadingState extends LoginState {
  const LoginLoadingState();

  @override
  List<Object> get props => [];
}

class SignupState extends AuthState {
  const SignupState();

  @override
  List<Object> get props => [];
}

class SignedupState extends SignupState {
  const SignedupState();

  @override
  List<Object> get props => [];
}

class SignupFailedState extends SignupState {
  const SignupFailedState(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

class SignupLoadingState extends SignupState {
  const SignupLoadingState();

  @override
  List<Object> get props => [];
}

class LogoutState extends AuthState {
  const LogoutState();

  @override
  List<Object> get props => [];
}

class LoggedoutState extends LogoutState {
  const LoggedoutState();

  @override
  List<Object> get props => [];
}

class LogoutFailedState extends LogoutState {
  const LogoutFailedState(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

class LogoutLoadingState extends LogoutState {
  const LogoutLoadingState();

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

class UnAuthenticatedState extends LoginState {
  const UnAuthenticatedState();

  @override
  List<Object> get props => [];
}

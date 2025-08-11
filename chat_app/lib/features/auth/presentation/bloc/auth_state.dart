// auth_state.dart (Recommended)
part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class Authenticated extends AuthState {
  final User? user;
  const Authenticated({required this.user});

  @override
  List<Object> get props => [user as Object];
}

final class Unauthenticated extends AuthState {}

final class AuthSuccess extends AuthState {
  final String message;
  const AuthSuccess(this.message);
  @override
  List<Object> get props => [message];
}

// An operation failed.
final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object> get props => [message];
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignupUseCase signupUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  AuthBloc({
    required this.signupUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await loginUseCase.call(event.email, event.password);
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(const LoggedinState()),
      );
    });
    on<SignupEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await signupUseCase.call(
        event.name,
        event.email,
        event.password,
      );
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(const SignedupState()),
      );
    });
    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await logoutUseCase.call();
        emit(const LoggedoutState());
      } on Failure catch (e) {
        emit(AuthError(message: e.message));
      }
    });
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/usecases/check_authenticated_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignupUseCase signupUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthenticatedUseCase checkAuthenticatedUseCase;
  AuthBloc({
    required this.signupUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthenticatedUseCase,
  }) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(const LoginLoadingState());
      final result = await loginUseCase.call(event.email, event.password);
      result.fold(
        (failure) => emit(LoginFailedState(failure.message)),
        (user) => emit(const LoggedinState()),
      );
    });
    on<SignupEvent>((event, emit) async {
      emit(const SignupLoadingState());
      final result = await signupUseCase.call(
        event.name,
        event.email,
        event.password,
      );
      result.fold(
        (failure) => emit(SignupFailedState(failure.message)),
        (user) => emit(const SignedupState()),
      );
    });
    on<LogoutEvent>((event, emit) async {
      emit(const LogoutLoadingState());
      try {
        await logoutUseCase.call();
        emit(const LoggedoutState());
      } on Failure catch (e) {
        emit(LogoutFailedState(e.message));
      }
    });
    on<CheckAuthenticatedEvent>((event, emit) async {
      emit(AuthInitial());
      final result = await checkAuthenticatedUseCase.call();
      if (result) {
        emit(const AuthenticatedState());
      } else {
        emit(const UnAuthenticatedState());
      }
    });
  }
}

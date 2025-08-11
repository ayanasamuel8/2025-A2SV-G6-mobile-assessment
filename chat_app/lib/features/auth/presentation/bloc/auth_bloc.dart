import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/check_authenticated_usecase.dart';
import '../../domain/usecases/get_me_usecase.dart';
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
  final GetMeUseCase getMeUseCase;
  final ChatRepository _chatRepository;

  AuthBloc({
    required this.signupUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthenticatedUseCase,
    required this.getMeUseCase,
    required ChatRepository chatRepository,
  }) : _chatRepository = chatRepository,
       super(AuthInitial()) {
    on<CheckAuthenticatedEvent>((event, emit) async {
      final result = await checkAuthenticatedUseCase.call();
      if (result) {
        await _authenticateAndGetUser(emit);
      } else {
        emit(Unauthenticated());
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await loginUseCase.call(event.email, event.password);
      await result.fold(
        (failure) async => emit(AuthFailure(failure.message)),
        (_) async => await _authenticateAndGetUser(emit),
      );
    });

    on<SignupEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await signupUseCase.call(
        event.name,
        event.email,
        event.password,
        event.confirmPassword,
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(const AuthSuccess('Signup successful! Please log in.')),
      );
    });

    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        _chatRepository.disconnect();
        await logoutUseCase.call();
        emit(Unauthenticated());
      } on Failure catch (e) {
        emit(AuthFailure(e.message));
      }
    });
  }
  Future<void> _authenticateAndGetUser(Emitter<AuthState> emit) async {
    final userResult = await getMeUseCase();
    try {
      await _chatRepository.connect();
    } catch (e) {
      print('Socket connection failed');
    }
    userResult.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }
}

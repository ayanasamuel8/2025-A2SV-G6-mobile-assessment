import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/domain/usecases/check_authenticated_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/signup_usecase.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSignupUseCase extends Mock implements SignupUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockCheckAuthenticatedUseCase extends Mock
    implements CheckAuthenticatedUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockSignupUseCase mockSignupUseCase;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockCheckAuthenticatedUseCase mockCheckAuthenticatedUseCase;

  setUp(() {
    mockSignupUseCase = MockSignupUseCase();
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockCheckAuthenticatedUseCase = MockCheckAuthenticatedUseCase();
    authBloc = AuthBloc(
      signupUseCase: mockSignupUseCase,
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      checkAuthenticatedUseCase: mockCheckAuthenticatedUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const tName = 'Test User';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tServerFailure = const ServerFailure('An error occurred');

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, equals(AuthInitial()));
  });

  group('LoginEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [LoginLoadingState, LoggedinState] when login is successful',
      build: () {
        when(
          () => mockLoginUseCase.call(any(), any()),
        ).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LoginEvent(email: tEmail, password: tPassword)),
      expect: () => [const LoginLoadingState(), const LoggedinState()],
      verify: (_) {
        verify(() => mockLoginUseCase.call(tEmail, tPassword)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [LoginLoadingState, LoginFailedState] when login fails',
      build: () {
        when(
          () => mockLoginUseCase.call(any(), any()),
        ).thenAnswer((_) async => Left(tServerFailure));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LoginEvent(email: tEmail, password: tPassword)),
      expect: () => [
        const LoginLoadingState(),
        LoginFailedState(tServerFailure.message),
      ],
      verify: (_) {
        verify(() => mockLoginUseCase.call(tEmail, tPassword)).called(1);
      },
    );
  });

  group('SignupEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [SignupLoadingState, SignedupState] when signup is successful',
      build: () {
        when(
          () => mockSignupUseCase.call(any(), any(), any()),
        ).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const SignupEvent(name: tName, email: tEmail, password: tPassword),
      ),
      expect: () => [const SignupLoadingState(), const SignedupState()],
      verify: (_) {
        verify(
          () => mockSignupUseCase.call(tName, tEmail, tPassword),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [SignupLoadingState, SignupFailedState] when signup fails',
      build: () {
        when(
          () => mockSignupUseCase.call(any(), any(), any()),
        ).thenAnswer((_) async => Left(tServerFailure));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const SignupEvent(name: tName, email: tEmail, password: tPassword),
      ),
      expect: () => [
        const SignupLoadingState(),
        SignupFailedState(tServerFailure.message),
      ],
      verify: (_) {
        verify(
          () => mockSignupUseCase.call(tName, tEmail, tPassword),
        ).called(1);
      },
    );
  });

  group('LogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [LogoutLoadingState, LoggedoutState] when logout is successful',
      build: () {
        when(() => mockLogoutUseCase.call()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutEvent()),
      expect: () => [const LogoutLoadingState(), const LoggedoutState()],
      verify: (_) {
        verify(() => mockLogoutUseCase.call()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [LogoutLoadingState, LogoutFailedState] when logout fails',
      build: () {
        when(() => mockLogoutUseCase.call()).thenThrow(tServerFailure);
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutEvent()),
      expect: () => [
        const LogoutLoadingState(),
        LogoutFailedState(tServerFailure.message),
      ],
      verify: (_) {
        verify(() => mockLogoutUseCase.call()).called(1);
      },
    );
  });

  group('CheckAuthenticatedEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthInitial, AuthenticatedState] when user is authenticated',
      build: () {
        when(
          () => mockCheckAuthenticatedUseCase.call(),
        ).thenAnswer((_) async => true);
        return authBloc;
      },
      act: (bloc) => bloc.add(const CheckAuthenticatedEvent()),
      expect: () => [AuthInitial(), const AuthenticatedState()],
      verify: (_) {
        verify(() => mockCheckAuthenticatedUseCase.call()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInitial, UnAuthenticatedState] when user is not authenticated',
      build: () {
        when(
          () => mockCheckAuthenticatedUseCase.call(),
        ).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(const CheckAuthenticatedEvent()),
      expect: () => [AuthInitial(), const UnAuthenticatedState()],
      verify: (_) {
        verify(() => mockCheckAuthenticatedUseCase.call()).called(1);
      },
    );
  });
}

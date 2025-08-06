import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/error/failure.dart';
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

void main() {
  late AuthBloc authBloc;
  late MockSignupUseCase mockSignupUseCase;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  setUp(() {
    mockSignupUseCase = MockSignupUseCase();
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    authBloc = AuthBloc(
      signupUseCase: mockSignupUseCase,
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
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
      'emits [AuthLoading, LoggedinState] when login is successful',
      build: () {
        when(
          () => mockLoginUseCase.call(any(), any()),
        ).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LoginEvent(email: tEmail, password: tPassword)),
      expect: () => [AuthLoading(), const LoggedinState()],
      verify: (_) {
        verify(() => mockLoginUseCase.call(tEmail, tPassword)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(
          () => mockLoginUseCase.call(any(), any()),
        ).thenAnswer((_) async => Left(tServerFailure));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LoginEvent(email: tEmail, password: tPassword)),
      expect: () => [AuthLoading(), AuthError(message: tServerFailure.message)],
      verify: (_) {
        verify(() => mockLoginUseCase.call(tEmail, tPassword)).called(1);
      },
    );
  });

  group('SignupEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, SignedupState] when signup is successful',
      build: () {
        when(
          () => mockSignupUseCase.call(any(), any(), any()),
        ).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const SignupEvent(name: tName, email: tEmail, password: tPassword),
      ),
      expect: () => [AuthLoading(), const SignedupState()],
      verify: (_) {
        verify(
          () => mockSignupUseCase.call(tName, tEmail, tPassword),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when signup fails',
      build: () {
        when(
          () => mockSignupUseCase.call(any(), any(), any()),
        ).thenAnswer((_) async => Left(tServerFailure));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const SignupEvent(name: tName, email: tEmail, password: tPassword),
      ),
      expect: () => [AuthLoading(), AuthError(message: tServerFailure.message)],
      verify: (_) {
        verify(
          () => mockSignupUseCase.call(tName, tEmail, tPassword),
        ).called(1);
      },
    );
  });

  group('LogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, LoggedoutState] when logout is successful',
      build: () {
        when(() => mockLogoutUseCase.call()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutEvent()),
      expect: () => [AuthLoading(), const LoggedoutState()],
      verify: (_) {
        verify(() => mockLogoutUseCase.call()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when logout fails',
      build: () {
        when(() => mockLogoutUseCase.call()).thenThrow(tServerFailure);
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutEvent()),
      expect: () => [AuthLoading(), AuthError(message: tServerFailure.message)],
      verify: (_) {
        verify(() => mockLogoutUseCase.call()).called(1);
      },
    );
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/auth/domain/usecases/check_authenticated_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/signup_usecase.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSignupUseCase extends Mock implements SignupUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockCheckAuthenticatedUseCase extends Mock
    implements CheckAuthenticatedUseCase {}

class MockGetMeUseCase extends Mock implements GetMeUseCase {}

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late AuthBloc authBloc;
  late MockSignupUseCase mockSignupUseCase;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockCheckAuthenticatedUseCase mockCheckAuthenticatedUseCase;
  late MockGetMeUseCase mockGetMeUseCase;
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockSignupUseCase = MockSignupUseCase();
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockCheckAuthenticatedUseCase = MockCheckAuthenticatedUseCase();
    mockGetMeUseCase = MockGetMeUseCase();
    mockChatRepository = MockChatRepository();
    authBloc = AuthBloc(
      signupUseCase: mockSignupUseCase,
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      checkAuthenticatedUseCase: mockCheckAuthenticatedUseCase,
      getMeUseCase: mockGetMeUseCase,
      chatRepository: mockChatRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const tName = 'Test User';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tConfirmPassword = 'password123';
  final tServerFailure = ServerFailure('An error occurred');
  final tUser = User(id: '1', name: tName, email: tEmail);

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, equals(AuthInitial()));
  });

  group('LoginEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when login is successful',
      build: () {
        when(
          () => mockLoginUseCase.call(any(), any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockGetMeUseCase.call(),
        ).thenAnswer((_) async => Right(tUser));
        when(() => mockChatRepository.connect()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LoginEvent(email: tEmail, password: tPassword)),
      expect: () => [AuthLoading(), Authenticated(user: tUser)],
      verify: (_) {
        verify(() => mockLoginUseCase.call(tEmail, tPassword)).called(1);
        verify(() => mockGetMeUseCase.call()).called(1);
        verify(() => mockChatRepository.connect()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login fails',
      build: () {
        when(
          () => mockLoginUseCase.call(any(), any()),
        ).thenAnswer((_) async => Left(tServerFailure));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LoginEvent(email: tEmail, password: tPassword)),
      expect: () => [AuthLoading(), AuthFailure(tServerFailure.message)],
      verify: (_) {
        verify(() => mockLoginUseCase.call(tEmail, tPassword)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when getMe fails after login',
      build: () {
        when(
          () => mockLoginUseCase.call(any(), any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockGetMeUseCase.call(),
        ).thenAnswer((_) async => Left(tServerFailure));
        when(() => mockChatRepository.connect()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LoginEvent(email: tEmail, password: tPassword)),
      expect: () => [AuthLoading(), AuthFailure(tServerFailure.message)],
      verify: (_) {
        verify(() => mockLoginUseCase.call(tEmail, tPassword)).called(1);
        verify(() => mockGetMeUseCase.call()).called(1);
        verify(() => mockChatRepository.connect()).called(1);
      },
    );
  });

  group('SignupEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when signup is successful',
      build: () {
        when(
          () => mockSignupUseCase.call(any(), any(), any(), any()),
        ).thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const SignupEvent(
          name: tName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ),
      ),
      expect: () => [
        AuthLoading(),
        const AuthSuccess('Signup successful! Please log in.'),
      ],
      verify: (_) {
        verify(
          () => mockSignupUseCase.call(
            tName,
            tEmail,
            tPassword,
            tConfirmPassword,
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when signup fails',
      build: () {
        when(
          () => mockSignupUseCase.call(any(), any(), any(), any()),
        ).thenAnswer((_) async => Left(tServerFailure));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const SignupEvent(
          name: tName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ),
      ),
      expect: () => [AuthLoading(), AuthFailure(tServerFailure.message)],
      verify: (_) {
        verify(
          () => mockSignupUseCase.call(
            tName,
            tEmail,
            tPassword,
            tConfirmPassword,
          ),
        ).called(1);
      },
    );
  });

  group('LogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when logout is successful',
      build: () {
        when(() => mockChatRepository.disconnect()).thenReturn(null);
        when(() => mockLogoutUseCase.call()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutEvent()),
      expect: () => [AuthLoading(), Unauthenticated()],
      verify: (_) {
        verify(() => mockChatRepository.disconnect()).called(1);
        verify(() => mockLogoutUseCase.call()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when logout fails',
      build: () {
        when(() => mockChatRepository.disconnect()).thenReturn(null);
        when(() => mockLogoutUseCase.call()).thenThrow(tServerFailure);
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutEvent()),
      expect: () => [AuthLoading(), AuthFailure(tServerFailure.message)],
      verify: (_) {
        verify(() => mockChatRepository.disconnect()).called(1);
        verify(() => mockLogoutUseCase.call()).called(1);
      },
    );
  });

  group('CheckAuthenticatedEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated] when user is authenticated',
      build: () {
        when(
          () => mockCheckAuthenticatedUseCase.call(),
        ).thenAnswer((_) async => true);
        when(
          () => mockGetMeUseCase.call(),
        ).thenAnswer((_) async => Right(tUser));
        when(() => mockChatRepository.connect()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const CheckAuthenticatedEvent()),
      expect: () => [Authenticated(user: tUser)],
      verify: (_) {
        verify(() => mockCheckAuthenticatedUseCase.call()).called(1);
        verify(() => mockGetMeUseCase.call()).called(1);
        verify(() => mockChatRepository.connect()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when user is not authenticated',
      build: () {
        when(
          () => mockCheckAuthenticatedUseCase.call(),
        ).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(const CheckAuthenticatedEvent()),
      expect: () => [Unauthenticated()],
      verify: (_) {
        verify(() => mockCheckAuthenticatedUseCase.call()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthFailure] when getMe fails after authenticated',
      build: () {
        when(
          () => mockCheckAuthenticatedUseCase.call(),
        ).thenAnswer((_) async => true);
        when(
          () => mockGetMeUseCase.call(),
        ).thenAnswer((_) async => Left(tServerFailure));
        when(() => mockChatRepository.connect()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const CheckAuthenticatedEvent()),
      expect: () => [AuthFailure(tServerFailure.message)],
      verify: (_) {
        verify(() => mockCheckAuthenticatedUseCase.call()).called(1);
        verify(() => mockGetMeUseCase.call()).called(1);
        verify(() => mockChatRepository.connect()).called(1);
      },
    );
  });
}

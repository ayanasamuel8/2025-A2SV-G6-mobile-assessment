import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:chat_app/features/auth/domain/usecases/signup_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignupUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignupUseCase(mockAuthRepository);
  });

  group('SignupUseCase', () {
    const tName = 'Test User';
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tConfirmPassword = 'password123';

    test(
      'should call AuthRepository.register with the correct parameters',
      () async {
        // Arrange
        when(
          () => mockAuthRepository.register(any(), any(), any(), any()),
        ).thenAnswer((_) async => const Right(null));

        // Act
        await usecase(tName, tEmail, tPassword, tConfirmPassword);
        // Assert
        verify(
          () => mockAuthRepository.register(
            tName,
            tEmail,
            tPassword,
            tConfirmPassword,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test(
      'should return a failure when repository.register was not successful',
      () async {
        // Arrange
        final tServerFailure = const ServerFailure('Registration failed');
        when(
          () => mockAuthRepository.register(any(), any(), any(), any()),
        ).thenAnswer((_) async => Left(tServerFailure));

        // Act
        final result = await usecase(
          tName,
          tEmail,
          tPassword,
          tConfirmPassword,
        );

        // Assert
        expect(result, equals(Left(tServerFailure)));
        verify(
          () => mockAuthRepository.register(
            tName,
            tEmail,
            tPassword,
            tConfirmPassword,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );
  });
}

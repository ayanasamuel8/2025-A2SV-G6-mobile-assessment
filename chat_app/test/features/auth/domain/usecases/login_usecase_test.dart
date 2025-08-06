import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:chat_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
  });

  group('LoginUseCase', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test('should call AuthRepository.login with correct parameters', () async {
      // arrange
      when(
        () => mockAuthRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase.call(tEmail, tPassword);

      // assert
      expect(result, const Right(null));
      verify(() => mockAuthRepository.login(tEmail, tPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test(
      'should return a failure when repository.login was not successful',
      () async {
        //arrange
        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenAnswer((_) async => const Left(ServerFailure('login failed')));

        //act
        final result = await usecase.call(tEmail, tPassword);

        //assert
        expect(result, const Left(ServerFailure('login failed')));
        verify(() => mockAuthRepository.login(tEmail, tPassword));
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );
  });
}

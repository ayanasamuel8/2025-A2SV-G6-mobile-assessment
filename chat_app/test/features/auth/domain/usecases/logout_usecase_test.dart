import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:chat_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutUseCase(mockAuthRepository);
  });

  group('LogoutUseCase', () {
    test('should call logout on the repository', () async {
      // Arrange
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => Future.value());

      // Act
      await usecase();

      // Assert
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should rethrow the exception when repository throws one', () async {
      // Arrange
      final tException = Exception('Something went wrong');
      when(() => mockAuthRepository.logout()).thenThrow(tException);

      // Act
      final call = usecase.call;

      // Assert
      expect(() => call(), throwsA(isA<Exception>()));
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}

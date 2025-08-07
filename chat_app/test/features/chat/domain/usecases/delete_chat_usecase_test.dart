import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/features/chat/domain/usecases/delete_chat_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late DeleteChatUseCase usecase;
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
    usecase = DeleteChatUseCase(mockChatRepository);
  });

  const tChatId = '1';
  const tToken = 'sample_token';
  final tServerFailure = const ServerFailure('Server error');

  test('should call deleteChat from the repository', () async {
    // arrange
    when(
      () => mockChatRepository.deleteChat(any(), any()),
    ).thenAnswer((_) async => const Right(null));
    // act
    final result = await usecase(tChatId, tToken);
    // assert
    expect(result, const Right(null));
    verify(() => mockChatRepository.deleteChat(tChatId, tToken));
    verifyNoMoreInteractions(mockChatRepository);
  });

  test(
    'should return a Failure when the call to repository is unsuccessful',
    () async {
      // arrange
      when(
        () => mockChatRepository.deleteChat(any(), any()),
      ).thenAnswer((_) async => Left(tServerFailure));
      // act
      final result = await usecase(tChatId, tToken);
      // assert
      expect(result, Left(tServerFailure));
      verify(() => mockChatRepository.deleteChat(tChatId, tToken));
      verifyNoMoreInteractions(mockChatRepository);
    },
  );
}

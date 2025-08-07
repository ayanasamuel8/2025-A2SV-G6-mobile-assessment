import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/features/chat/domain/usecases/get_chat_by_id_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late GetChatByIdUsecase usecase;
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
    usecase = GetChatByIdUsecase(mockChatRepository);
  });

  const tChatId = '1';
  const tToken = 'sample_token';
  final tChatEntity = ChatEntity(
    id: '1',
    sender: const User(
      id: 'user1',
      name: 'User One',
      email: 'user1@example.com',
    ),
    receiver: const User(
      id: 'user2',
      name: 'User Two',
      email: 'user2@example.com',
    ),
  );
  final tServerFailure = const ServerFailure('Server Error');

  test(
    'should get chat entity from the repository for the given chat id',
    () async {
      // arrange
      when(
        () => mockChatRepository.getChatById(any(), any()),
      ).thenAnswer((_) async => Right(tChatEntity));

      // act
      final result = await usecase(tChatId, tToken);

      // assert
      expect(result, Right(tChatEntity));
      verify(() => mockChatRepository.getChatById(tChatId, tToken));
      verifyNoMoreInteractions(mockChatRepository);
    },
  );

  test(
    'should return a failure when the call to repository is unsuccessful',
    () async {
      // arrange
      when(
        () => mockChatRepository.getChatById(any(), any()),
      ).thenAnswer((_) async => Left(tServerFailure));

      // act
      final result = await usecase(tChatId, tToken);

      // assert
      expect(result, Left(tServerFailure));
      verify(() => mockChatRepository.getChatById(tChatId, tToken));
      verifyNoMoreInteractions(mockChatRepository);
    },
  );
}

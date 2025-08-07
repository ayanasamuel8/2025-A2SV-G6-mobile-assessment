import 'package:chat_app/core/constants/message_type.dart';
import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late GetMessagesUsecase usecase;
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
    usecase = GetMessagesUsecase(mockChatRepository);
  });

  const tChatId = 'chat1';
  const tToken = 'token';
  final tMessages = [
    MessageEntity(
      messageId: '1',
      chatId: tChatId,
      sender: const User(
        id: 'user1',
        name: 'User 1',
        email: 'user1@example.com',
      ),
      content: 'Hello',
      type: MessageType.text,
    ),
    MessageEntity(
      messageId: '2',
      chatId: tChatId,
      sender: const User(
        id: 'user2',
        name: 'User 2',
        email: 'user2@example.com',
      ),
      content: 'Hi there',
      type: MessageType.text,
    ),
  ];
  final tFailure = const ServerFailure('Server error');

  test('should get list of messages from the repository', () async {
    // arrange
    when(
      () => mockChatRepository.getMessages(any(), any()),
    ).thenAnswer((_) async => Right(tMessages));

    // act
    final result = await usecase(tChatId, tToken);

    // assert
    expect(result, Right(tMessages));
    verify(() => mockChatRepository.getMessages(tChatId, tToken));
    verifyNoMoreInteractions(mockChatRepository);
  });

  test('should return a failure when the repository call fails', () async {
    // arrange
    when(
      () => mockChatRepository.getMessages(any(), any()),
    ).thenAnswer((_) async => Left(tFailure));

    // act
    final result = await usecase(tChatId, tToken);

    // assert
    expect(result, Left(tFailure));
    verify(() => mockChatRepository.getMessages(tChatId, tToken));
    verifyNoMoreInteractions(mockChatRepository);
  });
}

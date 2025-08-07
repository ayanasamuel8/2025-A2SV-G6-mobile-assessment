import 'package:chat_app/core/constants/message_type.dart';
import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
  });

  const tToken = 'sample_token';
  const tChatId = 'chat_id_1';
  const tReceiverId = 'receiver_id_1';
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
  final tMessageEntity = MessageEntity(
    messageId: 'message1',
    chatId: tChatId,
    sender: const User(
      id: 'user1',
      name: 'User One',
      email: 'user1@example.com',
    ),
    content: 'Hello',
    type: MessageType.text,
  );
  final tChatList = [tChatEntity];
  final tMessageList = [tMessageEntity];
  final tFailure = const ServerFailure('Server error');

  group('getChats', () {
    test('should return a list of ChatEntity on success', () async {
      // Arrange
      when(
        () => mockChatRepository.getChats(any()),
      ).thenAnswer((_) async => Right(tChatList));
      // Act
      final result = await mockChatRepository.getChats(tToken);
      // Assert
      expect(result, Right(tChatList));
      verify(() => mockChatRepository.getChats(tToken)).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });

    test('should return a Failure on error', () async {
      // Arrange
      when(
        () => mockChatRepository.getChats(any()),
      ).thenAnswer((_) async => Left(tFailure));
      // Act
      final result = await mockChatRepository.getChats(tToken);
      // Assert
      expect(result, Left(tFailure));
      verify(() => mockChatRepository.getChats(tToken)).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });
  });

  group('getChatById', () {
    test('should return a ChatEntity on success', () async {
      // Arrange
      when(
        () => mockChatRepository.getChatById(any(), any()),
      ).thenAnswer((_) async => Right(tChatEntity));
      // Act
      final result = await mockChatRepository.getChatById(tChatId, tToken);
      // Assert
      expect(result, Right(tChatEntity));
      verify(() => mockChatRepository.getChatById(tChatId, tToken)).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });

    test('should return a Failure on error', () async {
      // Arrange
      when(
        () => mockChatRepository.getChatById(any(), any()),
      ).thenAnswer((_) async => Left(tFailure));
      // Act
      final result = await mockChatRepository.getChatById(tChatId, tToken);
      // Assert
      expect(result, Left(tFailure));
      verify(() => mockChatRepository.getChatById(tChatId, tToken)).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });
  });

  group('getMessages', () {
    test('should return a list of MessageEntity on success', () async {
      // Arrange
      when(
        () => mockChatRepository.getMessages(any(), any()),
      ).thenAnswer((_) async => Right(tMessageList));
      // Act
      final result = await mockChatRepository.getMessages(tChatId, tToken);
      // Assert
      expect(result, Right(tMessageList));
      verify(() => mockChatRepository.getMessages(tChatId, tToken)).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });

    test('should return a Failure on error', () async {
      // Arrange
      when(
        () => mockChatRepository.getMessages(any(), any()),
      ).thenAnswer((_) async => Left(tFailure));
      // Act
      final result = await mockChatRepository.getMessages(tChatId, tToken);
      // Assert
      expect(result, Left(tFailure));
      verify(() => mockChatRepository.getMessages(tChatId, tToken)).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });
  });

  group('initiateChat', () {
    test('should return a ChatEntity on success', () async {
      // Arrange
      when(
        () => mockChatRepository.initiateChat(any(), any()),
      ).thenAnswer((_) async => Right(tChatEntity));
      // Act
      final result = await mockChatRepository.initiateChat(tReceiverId, tToken);
      // Assert
      expect(result, Right(tChatEntity));
      verify(
        () => mockChatRepository.initiateChat(tReceiverId, tToken),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });

    test('should return a Failure on error', () async {
      // Arrange
      when(
        () => mockChatRepository.initiateChat(any(), any()),
      ).thenAnswer((_) async => Left(tFailure));
      // Act
      final result = await mockChatRepository.initiateChat(tReceiverId, tToken);
      // Assert
      expect(result, Left(tFailure));
      verify(
        () => mockChatRepository.initiateChat(tReceiverId, tToken),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });
  });

  group('deleteChat', () {
    test('should return void (Right(null)) on success', () async {
      // Arrange
      when(
        () => mockChatRepository.deleteChat(any(), any()),
      ).thenAnswer((_) async => const Right(null));
      // Act
      final result = await mockChatRepository.deleteChat(tChatId, tToken);
      // Assert
      expect(result, const Right(null));
      verify(() => mockChatRepository.deleteChat(tChatId, tToken)).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });

    test('should return a Failure on error', () async {
      // Arrange
      when(
        () => mockChatRepository.deleteChat(any(), any()),
      ).thenAnswer((_) async => Left(tFailure));
      // Act
      final result = await mockChatRepository.deleteChat(tChatId, tToken);
      // Assert
      expect(result, Left(tFailure));
      verify(() => mockChatRepository.deleteChat(tChatId, tToken)).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });
  });
}

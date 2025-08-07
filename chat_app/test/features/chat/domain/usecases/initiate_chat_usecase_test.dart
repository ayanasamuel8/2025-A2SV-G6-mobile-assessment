import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/features/chat/domain/usecases/initiate_chat_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late InitiateChatUseCase usecase;
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
    usecase = InitiateChatUseCase(mockChatRepository);
  });

  const tReceiverId = 'receiver123';
  const tToken = 'user_token';
  final tChatEntity = ChatEntity(
    id: 'chat123',
    sender: const User(
      id: 'user123',
      name: 'User Name',
      email: 'user@example.com',
    ),
    receiver: const User(
      id: tReceiverId,
      name: 'Receiver Name',
      email: 'receiver@example.com',
    ),
  );
  const tFailure = ServerFailure('Server error');

  test(
    'should get chat entity from the repository when chat initiation is successful',
    () async {
      // Arrange
      when(
        () => mockChatRepository.initiateChat(any(), any()),
      ).thenAnswer((_) async => Right(tChatEntity));

      // Act
      final result = await usecase(tReceiverId, tToken);

      // Assert
      expect(result, Right(tChatEntity));
      verify(() => mockChatRepository.initiateChat(tReceiverId, tToken));
      verifyNoMoreInteractions(mockChatRepository);
    },
  );

  test(
    'should return a failure from the repository when chat initiation fails',
    () async {
      // Arrange
      when(
        () => mockChatRepository.initiateChat(any(), any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tReceiverId, tToken);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockChatRepository.initiateChat(tReceiverId, tToken));
      verifyNoMoreInteractions(mockChatRepository);
    },
  );
}

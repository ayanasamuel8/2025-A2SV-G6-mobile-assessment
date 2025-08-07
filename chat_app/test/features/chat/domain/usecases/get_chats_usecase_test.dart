import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late GetChatsUseCase usecase;
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
    usecase = GetChatsUseCase(mockChatRepository);
  });

  const tToken = 'sample_token';
  final tChatEntityList = [
    ChatEntity(
      id: '1',
      sender: const User(id: '1', name: 'User 1', email: 'user1@example.com'),
      receiver: const User(id: '2', name: 'User 2', email: 'user2@example.com'),
    ),
  ];
  final tServerFailure = const ServerFailure('Server error');

  test('should get list of chats from the repository', () async {
    // arrange
    when(
      () => mockChatRepository.getChats(any()),
    ).thenAnswer((_) async => Right(tChatEntityList));

    // act
    final result = await usecase(tToken);

    // assert
    expect(result, Right(tChatEntityList));
    verify(() => mockChatRepository.getChats(tToken));
    verifyNoMoreInteractions(mockChatRepository);
  });

  test('should return a failure when the repository call fails', () async {
    // arrange
    when(
      () => mockChatRepository.getChats(any()),
    ).thenAnswer((_) async => Left(tServerFailure));

    // act
    final result = await usecase(tToken);

    // assert
    expect(result, Left(tServerFailure));
    verify(() => mockChatRepository.getChats(tToken));
    verifyNoMoreInteractions(mockChatRepository);
  });
}

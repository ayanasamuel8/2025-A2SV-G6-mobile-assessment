import 'package:chat_app/core/error/exception.dart';
import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/data/datasources/local_data_source.dart';
import 'package:chat_app/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:chat_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chat_app/features/chat/data/models/chat_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:chat_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

class MockChatLocalDataSource extends Mock implements ChatLocalDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockChatModel extends Mock implements ChatModel {}

class MockMessageModel extends Mock implements MessageModel {}

void main() {
  late ChatRepositoryImpl repository;
  late MockChatRemoteDataSource mockRemote;
  late MockChatLocalDataSource mockLocal;
  late MockAuthLocalDataSource mockAuthLocal;

  const chatId = 'chat-1';
  const token = 'token-123';
  const receiverId = 'receiver-9';

  setUpAll(() {
    registerFallbackValue(MockChatModel());
    registerFallbackValue(<ChatModel>[]);
    registerFallbackValue(MockMessageModel());
    registerFallbackValue(<MessageModel>[]);
  });

  setUp(() {
    mockRemote = MockChatRemoteDataSource();
    mockLocal = MockChatLocalDataSource();
    mockAuthLocal = MockAuthLocalDataSource();
    repository = ChatRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      authLocalDataSource: mockAuthLocal,
    );
    when(() => mockAuthLocal.getToken()).thenAnswer((_) async => token);
  });

  group('deleteChat', () {
    test('returns Right(null) and clears local cache on success', () async {
      when(
        () => mockRemote.deleteChat(chatId, token),
      ).thenAnswer((_) async => Future.value());
      when(
        () => mockLocal.clearCacheForChat(chatId),
      ).thenAnswer((_) async => Future.value());

      final result = await repository.deleteChat(chatId);

      verify(() => mockAuthLocal.getToken()).called(1);
      verify(() => mockRemote.deleteChat(chatId, token)).called(1);
      verify(() => mockLocal.clearCacheForChat(chatId)).called(1);
      expect(result, isA<Right>());
    });

    test('swallows local cache errors and still returns Right(null)', () async {
      when(
        () => mockRemote.deleteChat(chatId, token),
      ).thenAnswer((_) async => Future.value());
      when(
        () => mockLocal.clearCacheForChat(chatId),
      ).thenThrow(CacheException());

      final result = await repository.deleteChat(chatId);

      verify(() => mockAuthLocal.getToken()).called(1);
      verify(() => mockRemote.deleteChat(chatId, token)).called(1);
      verify(() => mockLocal.clearCacheForChat(chatId)).called(1);
      result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
        expect(result, isA<Right>());
      });
    });

    test('returns Left(ServerFailure) when remote throws', () async {
      when(
        () => mockRemote.deleteChat(chatId, token),
      ).thenThrow(ServerException());

      final result = await repository.deleteChat(chatId);

      verify(() => mockAuthLocal.getToken()).called(1);
      verify(() => mockRemote.deleteChat(chatId, token)).called(1);
      verifyNever(() => mockLocal.clearCacheForChat(any()));
      result.fold((l) {
        expect(l, isA<ServerFailure>());
        expect(l.message, 'Failed to delete chat');
      }, (_) => fail('Expected Left'));
    });

    test('returns Left(UnauthorizedFailure) when token is null', () async {
      when(() => mockAuthLocal.getToken()).thenAnswer((_) async => null);

      final result = await repository.deleteChat(chatId);

      expect(result, isA<Left>());
      result.fold((l) {
        expect(l, isA<UnauthorizedFailure>());
      }, (_) => fail('Expected Left'));
    });
  });

  group('getChatById', () {
    test(
      'returns Right(ChatEntity) and caches chat and updates list (replace existing)',
      () async {
        final remoteChat = MockChatModel();
        final existingChatSameId = MockChatModel();

        when(() => remoteChat.id).thenReturn('id-1');
        when(() => existingChatSameId.id).thenReturn('id-1');

        when(
          () => mockRemote.getChatById('id-1', token),
        ).thenAnswer((_) async => remoteChat);
        when(
          () => mockLocal.cacheChat(remoteChat),
        ).thenAnswer((_) async => Future.value());
        when(
          () => mockLocal.getLastChats(),
        ).thenAnswer((_) async => <ChatModel>[existingChatSameId]);
        when(
          () => mockLocal.cacheChats(any()),
        ).thenAnswer((_) async => Future.value());

        final result = await repository.getChatById('id-1');

        result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
          expect(r, same(remoteChat));
        });

        verify(() => mockAuthLocal.getToken()).called(1);
        verify(() => mockLocal.cacheChat(remoteChat)).called(1);
        final captured =
            verify(() => mockLocal.cacheChats(captureAny())).captured.single
                as List<ChatModel>;
        expect(captured.length, 1);
        expect(identical(captured.first, remoteChat), isTrue);
        expect(captured.first.id, 'id-1');
      },
    );

    test(
      'returns Right(ChatEntity) and caches chat and updates list (insert new at 0)',
      () async {
        final remoteChat = MockChatModel();
        final otherChat = MockChatModel();

        when(() => remoteChat.id).thenReturn('new-id');
        when(() => otherChat.id).thenReturn('old-id');

        when(
          () => mockRemote.getChatById('new-id', token),
        ).thenAnswer((_) async => remoteChat);
        when(
          () => mockLocal.cacheChat(remoteChat),
        ).thenAnswer((_) async => Future.value());
        when(
          () => mockLocal.getLastChats(),
        ).thenAnswer((_) async => <ChatModel>[otherChat]);
        when(
          () => mockLocal.cacheChats(any()),
        ).thenAnswer((_) async => Future.value());

        final result = await repository.getChatById('new-id');

        result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
          expect(r, same(remoteChat));
        });

        final captured =
            verify(() => mockLocal.cacheChats(captureAny())).captured.single
                as List<ChatModel>;
        expect(captured.length, 2);
        expect(identical(captured.first, remoteChat), isTrue);
        expect(captured.last.id, 'old-id');
      },
    );

    test('falls back to cache on ServerException', () async {
      final cachedChat = MockChatModel();
      when(() => cachedChat.id).thenReturn('cached-id');

      when(
        () => mockRemote.getChatById('cached-id', token),
      ).thenThrow(ServerException());
      when(
        () => mockLocal.getLastChatById('cached-id'),
      ).thenAnswer((_) async => cachedChat);

      final result = await repository.getChatById('cached-id');

      verify(() => mockAuthLocal.getToken()).called(1);
      verify(() => mockLocal.getLastChatById('cached-id')).called(1);

      result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
        expect(r, same(cachedChat));
      });
    });

    test(
      'returns Left(ServerFailure) when both remote and cache fail',
      () async {
        when(
          () => mockRemote.getChatById(any(), any()),
        ).thenThrow(ServerException());
        when(
          () => mockLocal.getLastChatById(any()),
        ).thenThrow(CacheException());

        final result = await repository.getChatById('x');

        result.fold((l) {
          expect(l, isA<ServerFailure>());
          expect(l.message, 'Failed to get chat by id');
        }, (_) => fail('Expected Left'));
      },
    );

    test(
      'swallows cache errors during cache write after remote success',
      () async {
        final remoteChat = MockChatModel();
        when(() => remoteChat.id).thenReturn('id-x');

        when(
          () => mockRemote.getChatById('id-x', token),
        ).thenAnswer((_) async => remoteChat);
        when(() => mockLocal.cacheChat(remoteChat)).thenThrow(CacheException());
        final result = await repository.getChatById('id-x');

        result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
          expect(r, same(remoteChat));
        });
      },
    );

    test('returns Left(UnauthorizedFailure) when token is null', () async {
      when(() => mockAuthLocal.getToken()).thenAnswer((_) async => null);

      final result = await repository.getChatById('id-x');

      expect(result, isA<Left>());
      result.fold((l) {
        expect(l, isA<UnauthorizedFailure>());
      }, (_) => fail('Expected Left'));
    });
  });

  group('getChats', () {
    test('falls back to cached chats on ServerException', () async {
      final cached = <ChatModel>[MockChatModel()];
      when(() => mockRemote.getChats(any())).thenThrow(ServerException());
      when(() => mockLocal.getLastChats()).thenAnswer((_) async => cached);

      final result = await repository.getChats();

      verify(() => mockLocal.getLastChats()).called(1);
      result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
        expect(r.length, 1);
      });
    });

    test(
      'returns Left(ServerFailure) when both remote and cache fail',
      () async {
        when(() => mockRemote.getChats(any())).thenThrow(ServerException());
        when(() => mockLocal.getLastChats()).thenThrow(CacheException());

        final result = await repository.getChats();

        result.fold((l) {
          expect(l, isA<ServerFailure>());
          expect(l.message, 'Failed to get chats');
        }, (_) => fail('Expected Left'));
      },
    );

    test(
      'does not attempt to cache when remote returns non-ChatModel items',
      () async {
        when(
          () => mockRemote.getChats(any()),
        ).thenAnswer((_) async => <ChatModel>[]);
        final result = await repository.getChats();

        verifyNever(() => mockLocal.cacheChats(any()));
        result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
          expect(r, isEmpty);
        });
      },
    );

    test('returns Left(UnauthorizedFailure) when token is null', () async {
      when(() => mockAuthLocal.getToken()).thenAnswer((_) async => null);

      final result = await repository.getChats();

      expect(result, isA<Left>());
      result.fold((l) {
        expect(l, isA<UnauthorizedFailure>());
      }, (_) => fail('Expected Left'));
    });
  });

  group('getMessages', () {
    test(
      'returns Right(List<MessageEntity>) and caches models on success',
      () async {
        final m1 = MockMessageModel();
        final m2 = MockMessageModel();

        final remoteList = <MessageModel>[m1, m2];
        when(
          () => mockRemote.getMessages(chatId, token),
        ).thenAnswer((_) async => remoteList);
        when(
          () => mockLocal.cacheMessages(any(), any()),
        ).thenAnswer((_) async => Future.value());

        final result = await repository.getMessages(chatId);

        result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
          expect(r.length, 2);
        });

        final captured =
            verify(
                  () => mockLocal.cacheMessages(chatId, captureAny()),
                ).captured.single
                as List<MessageModel>;
        expect(captured.length, 2);
      },
    );

    test('falls back to cached messages on ServerException', () async {
      final cached = <MessageModel>[MockMessageModel()];
      when(
        () => mockRemote.getMessages(any(), any()),
      ).thenThrow(ServerException());
      when(
        () => mockLocal.getLastMessages(chatId),
      ).thenAnswer((_) async => cached);

      final result = await repository.getMessages(chatId);

      verify(() => mockLocal.getLastMessages(chatId)).called(1);
      result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
        expect(r.length, 1);
      });
    });

    test(
      'returns Left(ServerFailure) when both remote and cache fail',
      () async {
        when(
          () => mockRemote.getMessages(any(), any()),
        ).thenThrow(ServerException());
        when(
          () => mockLocal.getLastMessages(any()),
        ).thenThrow(CacheException());

        final result = await repository.getMessages(chatId);

        result.fold((l) {
          expect(l, isA<ServerFailure>());
          expect(l.message, 'Failed to get messages');
        }, (_) => fail('Expected Left'));
      },
    );

    test(
      'does not attempt to cache when remote returns non-MessageModel items',
      () async {
        when(
          () => mockRemote.getMessages(any(), any()),
        ).thenAnswer((_) async => <MessageModel>[]);
        final result = await repository.getMessages(chatId);

        verifyNever(() => mockLocal.cacheMessages(any(), any()));
        result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
          expect(r, isEmpty);
        });
      },
    );

    test('returns Left(UnauthorizedFailure) when token is null', () async {
      when(() => mockAuthLocal.getToken()).thenAnswer((_) async => null);

      final result = await repository.getMessages(chatId);

      expect(result, isA<Left>());
      result.fold((l) {
        expect(l, isA<UnauthorizedFailure>());
      }, (_) => fail('Expected Left'));
    });
  });

  group('initiateChat', () {
    test(
      'returns Right(ChatEntity) and caches chat and updates list',
      () async {
        final newChat = MockChatModel();
        final oldChat = MockChatModel();

        when(() => newChat.id).thenReturn('new');
        when(() => oldChat.id).thenReturn('old');

        when(
          () => mockRemote.initiateChat(receiverId, token),
        ).thenAnswer((_) async => newChat);
        when(
          () => mockLocal.cacheChat(newChat),
        ).thenAnswer((_) async => Future.value());
        when(
          () => mockLocal.getLastChats(),
        ).thenAnswer((_) async => <ChatModel>[oldChat]);
        when(
          () => mockLocal.cacheChats(any()),
        ).thenAnswer((_) async => Future.value());

        final result = await repository.initiateChat(receiverId);

        result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
          expect(r, same(newChat));
        });

        verify(() => mockAuthLocal.getToken()).called(1);
        verify(() => mockLocal.cacheChat(newChat)).called(1);
        final captured =
            verify(() => mockLocal.cacheChats(captureAny())).captured.single
                as List<ChatModel>;
        expect(captured.length, 2);
        expect(identical(captured.first, newChat), isTrue);
        expect(captured.last.id, 'old');
      },
    );

    test(
      'swallows cache errors and still returns Right on remote success',
      () async {
        final newChat = MockChatModel();
        when(() => newChat.id).thenReturn('new');

        when(
          () => mockRemote.initiateChat(any(), any()),
        ).thenAnswer((_) async => newChat);
        when(() => mockLocal.cacheChat(newChat)).thenThrow(CacheException());

        final result = await repository.initiateChat(receiverId);

        result.fold((l) => fail('Expected Right, got Left: $l'), (r) {
          expect(r, same(newChat));
        });
      },
    );

    test('returns Left(ServerFailure) when remote throws', () async {
      when(
        () => mockRemote.initiateChat(any(), any()),
      ).thenThrow(ServerException());

      final result = await repository.initiateChat(receiverId);

      result.fold((l) {
        expect(l, isA<ServerFailure>());
        expect(l.message, 'Failed to initiate chat');
      }, (_) => fail('Expected Left'));
    });

    test('returns Left(UnauthorizedFailure) when token is null', () async {
      when(() => mockAuthLocal.getToken()).thenAnswer((_) async => null);

      final result = await repository.initiateChat(receiverId);

      expect(result, isA<Left>());
      result.fold((l) {
        expect(l, isA<UnauthorizedFailure>());
      }, (_) => fail('Expected Left'));
    });
  });
}

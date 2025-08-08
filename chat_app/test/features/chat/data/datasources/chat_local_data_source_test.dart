import 'dart:convert';

import 'package:chat_app/core/constants/shared_prefrences_key.dart';
import 'package:chat_app/core/error/exception.dart';
import 'package:chat_app/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:chat_app/features/chat/data/models/chat_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockChatModel extends Mock implements ChatModel {}

class MockMessageModel extends Mock implements MessageModel {}

void main() {
  late MockSharedPreferences mockPrefs;
  late ChatLocalDataSourceImpl dataSource;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    dataSource = ChatLocalDataSourceImpl(sharedPreferences: mockPrefs);
  });

  group('cacheChats', () {
    test('calls SharedPreferences.setStringList with encoded chats', () async {
      final chat1 = MockChatModel();
      final chat2 = MockChatModel();

      when(() => chat1.id).thenReturn('c1');
      when(() => chat2.id).thenReturn('c2');
      final map1 = {'id': 'c1', 'name': 'Chat 1'};
      final map2 = {'id': 'c2', 'name': 'Chat 2'};
      when(() => chat1.toJson()).thenReturn(map1);
      when(() => chat2.toJson()).thenReturn(map2);

      when(
        () => mockPrefs.setStringList(any(), any()),
      ).thenAnswer((_) async => true);

      await dataSource.cacheChats([chat1, chat2]);

      final expected = [json.encode(map1), json.encode(map2)];
      verify(
        () => mockPrefs.setStringList(
          cachedChatsList,
          any<List<String>>(
            that: predicate<List<String>>(
              (l) =>
                  l.length == 2 && l[0] == expected[0] && l[1] == expected[1],
            ),
          ),
        ),
      ).called(1);
    });
  });

  group('getLastChats', () {
    test('returns empty list when cached list is empty', () async {
      when(() => mockPrefs.getStringList(cachedChatsList)).thenReturn([]);

      final result = await dataSource.getLastChats();

      expect(result, isA<List<ChatModel>>());
      expect(result, isEmpty);
    });

    test('throws CacheException when no cached chats', () async {
      when(() => mockPrefs.getStringList(cachedChatsList)).thenReturn(null);

      expect(() => dataSource.getLastChats(), throwsA(isA<CacheException>()));
    });
  });

  group('cacheChat', () {
    test(
      'calls SharedPreferences.setString with encoded chat and key by id',
      () async {
        final chat = MockChatModel();
        when(() => chat.id).thenReturn('c1');
        final map = {'id': 'c1', 'name': 'Chat 1'};
        when(() => chat.toJson()).thenReturn(map);
        when(
          () => mockPrefs.setString(any(), any()),
        ).thenAnswer((_) async => true);

        await dataSource.cacheChat(chat);

        verify(
          () => mockPrefs.setString(
            '$cachedChatPrefix${chat.id}',
            json.encode(map),
          ),
        ).called(1);
      },
    );
  });

  group('getLastChatById', () {
    test('throws CacheException when no cached chat for id', () async {
      const chatId = 'missing';
      when(
        () => mockPrefs.getString('$cachedChatPrefix$chatId'),
      ).thenReturn(null);

      expect(
        () => dataSource.getLastChatById(chatId),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('cacheMessages', () {
    test(
      'calls SharedPreferences.setStringList with encoded messages for chatId',
      () async {
        const chatId = 'c1';
        final m1 = MockMessageModel();
        final m2 = MockMessageModel();
        final map1 = {'id': 'm1', 'text': 'Hello'};
        final map2 = {'id': 'm2', 'text': 'World'};

        when(() => m1.toJson()).thenReturn(map1);
        when(() => m2.toJson()).thenReturn(map2);
        when(
          () => mockPrefs.setStringList(any(), any()),
        ).thenAnswer((_) async => true);

        await dataSource.cacheMessages(chatId, [m1, m2]);

        final expected = [json.encode(map1), json.encode(map2)];
        verify(
          () => mockPrefs.setStringList(
            '$cachedMessagesPrefix$chatId',
            any<List<String>>(
              that: predicate<List<String>>(
                (l) =>
                    l.length == 2 && l[0] == expected[0] && l[1] == expected[1],
              ),
            ),
          ),
        ).called(1);
      },
    );
  });

  group('getLastMessages', () {
    test('returns empty list when cached list is empty for chatId', () async {
      const chatId = 'c1';
      when(
        () => mockPrefs.getStringList('$cachedMessagesPrefix$chatId'),
      ).thenReturn([]);

      final result = await dataSource.getLastMessages(chatId);

      expect(result, isA<List<MessageModel>>());
      expect(result, isEmpty);
    });

    test('throws CacheException when no cached messages for chatId', () async {
      const chatId = 'c1';
      when(
        () => mockPrefs.getStringList('$cachedMessagesPrefix$chatId'),
      ).thenReturn(null);

      expect(
        () => dataSource.getLastMessages(chatId),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('clearCacheForChat', () {
    test(
      'removes chat and messages keys and does not update list when no list cache',
      () async {
        const chatId = 'c1';
        when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
        when(() => mockPrefs.getStringList(cachedChatsList)).thenReturn(null);

        await dataSource.clearCacheForChat(chatId);

        verify(() => mockPrefs.remove('$cachedChatPrefix$chatId')).called(1);
        verify(
          () => mockPrefs.remove('$cachedMessagesPrefix$chatId'),
        ).called(1);
        verifyNever(() => mockPrefs.setStringList(any(), any()));
      },
    );

    test(
      'removes chat, messages and updates cached chat list when list exists (empty)',
      () async {
        const chatId = 'c1';
        when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
        when(() => mockPrefs.getStringList(cachedChatsList)).thenReturn([]);
        when(
          () => mockPrefs.setStringList(any(), any()),
        ).thenAnswer((_) async => true);

        await dataSource.clearCacheForChat(chatId);

        verify(() => mockPrefs.remove('$cachedChatPrefix$chatId')).called(1);
        verify(
          () => mockPrefs.remove('$cachedMessagesPrefix$chatId'),
        ).called(1);
        verify(
          () => mockPrefs.setStringList(
            cachedChatsList,
            any<List<String>>(that: predicate<List<String>>((l) => l.isEmpty)),
          ),
        ).called(1);
      },
    );
  });
}

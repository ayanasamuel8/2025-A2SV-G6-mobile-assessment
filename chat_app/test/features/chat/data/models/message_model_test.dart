import 'package:chat_app/core/constants/message_type.dart';
import 'package:chat_app/features/auth/data/models/user.dart';
import 'package:chat_app/features/chat/data/models/chat_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // --- 1. Test Data Setup ---
  // Create sample data that will be used across all tests.
  final tTimestamp = DateTime.parse('2023-10-27T10:00:00.000Z');

  const tUserModel = UserModel(
    id: 'user1',
    name: 'Test User',
    email: 'test@example.com',
  );

  const tChatModel = ChatModel(
    id: 'chat1',
    user1: tUserModel,
    user2: UserModel(id: 'user2', name: 'Other User', email: 'other@test.com'),
  );

  final tMessageModel = MessageModel(
    messageId: 'msg1',
    chatId: 'chat1',
    chat: tChatModel,
    sender: tUserModel,
    content: 'Hello, World!',
    type: MessageType.text,
    timestamp: tTimestamp,
    status: MessageStatus.delivered,
  );

  // --- 2. Main Group for MessageModel Tests ---
  group('MessageModel', () {
    // --- Test 2a: Inheritance Check ---
    // A simple but important test for Clean Architecture.
    test('should be a subclass of MessageEntity', () {
      // Assert
      expect(tMessageModel, isA<MessageEntity>());
    });

    // --- Test 2b: fromJson Factory ---
    group('fromJson', () {
      test(
        'should return a valid MessageModel when the JSON is properly formatted',
        () {
          // Arrange
          // Create a JSON map that perfectly mimics the server's response.
          final Map<String, dynamic> jsonMap = {
            '_id': 'msg1',
            'chat': {
              '_id': 'chat1',
              'user1': {
                '_id': 'user1',
                'name': 'Test User',
                'email': 'test@example.com',
              },
              'user2': {
                '_id': 'user2',
                'name': 'Other User',
                'email': 'other@test.com',
              },
            },
            'sender': {
              '_id': 'user1',
              'name': 'Test User',
              'email': 'test@example.com',
            },
            'content': 'Hello, World!',
            'type': 'text',
            'status': 'delivered',
            'timestamp': '2023-10-27T10:00:00.000Z',
          };

          // Act
          // Call the fromJson method to create a model from the map.
          final result = MessageModel.fromJson(jsonMap);

          // Assert
          // Check if the resulting model matches our sample model.
          // This works because MessageEntity (and MessageModel) use Equatable.
          expect(result, tMessageModel);
        },
      );

      // NOTE: This fromJson implementation is brittle. If 'sender' or 'chat' were null
      // in the JSON, this test would crash. Our previous refactoring made the production
      // code safe, but your provided code for this test does not have those null checks.
    });

    // --- Test 2c: toJson Method ---
    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        // Act
        // Convert our sample MessageModel into a map.
        final result = tMessageModel.toJson();

        // Assert
        // Define the expected map structure.
        final expectedMap = {
          '_id': 'msg1',
          'chatId':
              'chat1', // Note: your toJson has chatId, but not the full chat object.
          'sender': {
            '_id': 'user1',
            'name': 'Test User',
            'email': 'test@example.com',
          },
          'content': 'Hello, World!',
          'type': 'text',
          'status': 'delivered',
          'timestamp': '2023-10-27T10:00:00.000Z',
        };

        // Check if the result matches the expected map.
        expect(result, expectedMap);
      });
    });

    // --- Test 2d: toEntity Method ---
    group('toEntity', () {
      test('should return a MessageEntity with the same data', () {
        // Act
        final result = tMessageModel.toEntity();

        // Assert
        // Verify that it is a MessageEntity and the core data is the same.
        expect(result, isA<MessageEntity>());
        expect(result.messageId, tMessageModel.messageId);
        expect(result.content, tMessageModel.content);
      });
    });
  });
}

import 'package:chat_app/features/auth/data/models/user.dart';
import 'package:chat_app/features/chat/data/models/chat_model.dart';
import 'package:chat_app/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tSenderModel = UserModel(
    id: 'senderId',
    name: 'Sender Name',
    email: 'sender@example.com',
  );

  const tReceiverModel = UserModel(
    id: 'receiverId',
    name: 'Receiver Name',
    email: 'receiver@example.com',
  );

  final tChatModel = ChatModel(
    id: 'chatId1',
    sender: tSenderModel,
    receiver: tReceiverModel,
  );

  group('ChatModel', () {
    test('should be a subclass of ChatEntity', () async {
      // Assert
      expect(tChatModel, isA<ChatEntity>());
    });

    group('fromJson', () {
      test('should return a valid model when the JSON is valid', () async {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'chatId1',
          'sender': {
            'id': 'senderId',
            'name': 'Sender Name',
            'email': 'sender@example.com',
          },
          'receiver': {
            'id': 'receiverId',
            'name': 'Receiver Name',
            'email': 'receiver@example.com',
          },
        };

        // Act
        final result = ChatModel.fromJson(jsonMap);

        // Assert
        expect(result, tChatModel);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () async {
        // Act
        final result = tChatModel.toJson();

        // Assert
        final expectedMap = {
          'id': 'chatId1',
          'sender': {
            'id': 'senderId',
            'name': 'Sender Name',
            'email': 'sender@example.com',
          },
          'receiver': {
            'id': 'receiverId',
            'name': 'Receiver Name',
            'email': 'receiver@example.com',
          },
        };
        expect(result, expectedMap);
      });
    });

    group('toEntity', () {
      test('should return a ChatEntity with the same properties', () async {
        // Act
        final entity = tChatModel.toEntity();

        // Assert
        expect(entity, isA<ChatEntity>());
        expect(entity.id, tChatModel.id);
        expect(entity.sender, tChatModel.sender);
        expect(entity.receiver, tChatModel.receiver);
      });
    });
  });
}

import 'package:chat_app/core/constants/message_type.dart';
import 'package:chat_app/features/auth/data/models/user.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tUserModel = UserModel(
    id: '1',
    email: 'test@test.com',
    name: 'testuser',
  );

  const tMessageModel = MessageModel(
    messageId: '1',
    chatId: 'chat1',
    sender: tUserModel,
    content: 'Hello',
    type: MessageType.text,
  );

  final tJsonMap = {
    'messageId': '1',
    'chatId': 'chat1',
    'sender': {'id': '1', 'name': 'testuser', 'email': 'test@test.com'},
    'content': 'Hello',
    'type': 'text',
  };

  group('MessageModel', () {
    test('should be a subclass of MessageEntity', () {
      // Assert
      expect(tMessageModel, isA<MessageEntity>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        // Act
        final result = MessageModel.fromJson(tJsonMap);
        // Assert
        expect(result, tMessageModel);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        // Act
        final result = tMessageModel.toJson();
        // Assert
        expect(result, tJsonMap);
      });
    });

    group('toEntity', () {
      test('should return a MessageEntity with the same data', () {
        // Act
        final result = tMessageModel.toEntity();
        // Assert
        expect(result, isA<MessageEntity>());
        expect(result.messageId, tMessageModel.messageId);
        expect(result.chatId, tMessageModel.chatId);
        expect(result.sender, tMessageModel.sender);
        expect(result.content, tMessageModel.content);
        expect(result.type, tMessageModel.type);
      });
    });
  });
}

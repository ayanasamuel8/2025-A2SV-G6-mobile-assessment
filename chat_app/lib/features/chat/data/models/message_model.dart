import '../../../../core/constants/message_type.dart';
import '../../../auth/data/models/user.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.messageId,
    required super.chatId,
    required super.sender,
    required super.content,
    required super.type,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'] as String,
      chatId: json['chatId'] as String,
      sender: UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      content: json['content'] as String,
      type: MessageType.values.byName(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'sender': (sender as UserModel).toJson(),
      'content': content,
      'type': type.name,
    };
  }

  MessageEntity toEntity() {
    return MessageEntity(
      messageId: messageId,
      chatId: chatId,
      sender: sender,
      content: content,
      type: type,
    );
  }
}

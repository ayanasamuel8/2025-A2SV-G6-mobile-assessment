import '../../../../core/constants/message_type.dart';
import '../../../auth/data/models/user.dart';
import '../../domain/entities/message_entity.dart';
import 'chat_model.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.messageId,
    required super.chatId,
    required super.sender,
    required super.chat,
    required super.content,
    super.status = MessageStatus.sent,
    required super.type,
    required super.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['_id'] as String,
      chatId: json['chat']['_id'] as String,
      chat: ChatModel.fromJson(json['chat'] as Map<String, dynamic>),
      sender: UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      content: json['content'] as String,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'] as String,
        orElse: () => MessageStatus.sent,
      ),
      type: MessageType.values.byName(json['type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': messageId,
      'chatId': chatId,
      'sender': (sender as UserModel).toJson(),
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  MessageEntity toEntity() {
    return MessageEntity(
      messageId: messageId,
      chatId: chatId,
      chat: chat,
      sender: sender,
      content: content,
      type: type,
      timestamp: timestamp,
      status: status,
    );
  }
}

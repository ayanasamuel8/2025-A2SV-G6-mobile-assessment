import 'package:equatable/equatable.dart';

import '../../../../core/constants/message_type.dart';
import '../../../auth/domain/entities/user.dart';
import 'chat_entity.dart';

enum MessageStatus {
  sending,
  sent,
  delivered,
  read;

  String toJson() => name;
}

class MessageEntity extends Equatable {
  final String messageId;
  final String chatId;
  final ChatEntity chat;
  final User sender;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;

  const MessageEntity({
    required this.messageId,
    required this.chatId,
    required this.chat,
    required this.sender,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  MessageEntity copyWith({
    String? messageId,
    String? content,
    String? chatId,
    ChatEntity? chat,
    User? sender,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return MessageEntity(
      messageId: messageId ?? this.messageId,
      content: content ?? this.content,
      chatId: chatId ?? this.chatId,
      chat: chat ?? this.chat,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    messageId,
    chatId,
    chat,
    sender,
    content,
    type,
    timestamp,
    status,
  ];
}

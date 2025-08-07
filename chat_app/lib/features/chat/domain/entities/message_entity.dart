import '../../../../core/constants/message_type.dart';
import '../../../auth/domain/entities/user.dart';

class MessageEntity {
  final String messageId;
  final String chatId;
  final User sender;
  final String content;
  final MessageType type;

  MessageEntity({
    required this.messageId,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.type,
  });
}

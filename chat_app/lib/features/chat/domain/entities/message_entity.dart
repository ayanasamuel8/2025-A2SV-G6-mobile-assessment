import 'package:equatable/equatable.dart';

import '../../../../core/constants/message_type.dart';
import '../../../auth/domain/entities/user.dart';

class MessageEntity extends Equatable {
  final String messageId;
  final String chatId;
  final User sender;
  final String content;
  final MessageType type;

  const MessageEntity({
    required this.messageId,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.type,
  });

  @override
  List<Object?> get props => [messageId, chatId, sender, content, type];
}

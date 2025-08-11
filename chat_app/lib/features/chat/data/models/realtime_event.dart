import '../../domain/entities/message_entity.dart';

sealed class RealtimeEvent {}

/// Represents a brand new message received from another user.
class NewMessageEvent extends RealtimeEvent {
  final MessageEntity message;
  NewMessageEvent(this.message);
}

/// Represents a status update for an existing message.
class MessageStatusUpdateEvent extends RealtimeEvent {
  final String messageId;
  final MessageStatus newStatus;
  MessageStatusUpdateEvent(this.messageId, this.newStatus);
}

class MessageSentEvent extends RealtimeEvent {
  final String tempId; // Temporary ID used for optimistic UI updates
  final MessageEntity confirmedMessage; // The message that was confirmed sent
  MessageSentEvent(this.tempId, this.confirmedMessage);
}

/// Represents an error received from the socket connection.
class RealtimeErrorEvent extends RealtimeEvent {
  final String errorMessage;
  RealtimeErrorEvent(this.errorMessage);
}

class MessagesHaveBeenReadEvent extends RealtimeEvent {
  final String chatId; // The ID of the chat where messages were read
  MessagesHaveBeenReadEvent(this.chatId);
}

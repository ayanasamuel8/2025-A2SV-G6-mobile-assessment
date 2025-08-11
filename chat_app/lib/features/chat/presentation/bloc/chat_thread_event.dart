part of 'chat_thread_bloc.dart';

sealed class ChatThreadEvent extends Equatable {
  const ChatThreadEvent();

  @override
  List<Object> get props => [];
}

final class FetchThreadDataEvent extends ChatThreadEvent {
  final String chatId;
  const FetchThreadDataEvent({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

final class InitiateChatEvent extends ChatThreadEvent {
  final String receiverId;
  const InitiateChatEvent({required this.receiverId});

  @override
  List<Object> get props => [receiverId];
}

final class SendMessageEvent extends ChatThreadEvent {
  final String content;
  final MessageType type; // Assuming you have a MessageType enum

  const SendMessageEvent({required this.content, required this.type});
  @override
  List<Object> get props => [content, type];
}

final class _NewMessageReceived extends ChatThreadEvent {
  final MessageEntity message;
  const _NewMessageReceived(this.message);
}

final class _ChatMarkedAsRead extends ChatThreadEvent {
  final String chatId;
  const _ChatMarkedAsRead(this.chatId);
}

final class _RealtimeErrorOccurred extends ChatThreadEvent {
  final String message;
  const _RealtimeErrorOccurred(this.message);
}

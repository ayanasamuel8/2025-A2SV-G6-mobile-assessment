part of 'chat_list_bloc.dart';

sealed class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch the entire list of chats.
final class GetChatsListEvent extends ChatListEvent {}

/// Event to delete a specific chat conversation.
final class DeleteChatEvent extends ChatListEvent {
  final String chatId;
  const DeleteChatEvent({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

final class _NewMessageForListReceived extends ChatListEvent {
  final MessageEntity message;
  const _NewMessageForListReceived(this.message);
  @override
  List<Object> get props => [message];
}

final class _ChatInListMarkedAsRead extends ChatListEvent {
  final String chatId;
  const _ChatInListMarkedAsRead(this.chatId);
  @override
  List<Object> get props => [chatId];
}

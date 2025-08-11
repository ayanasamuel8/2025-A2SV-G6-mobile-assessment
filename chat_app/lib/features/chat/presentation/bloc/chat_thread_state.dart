part of 'chat_thread_bloc.dart';

sealed class ChatThreadState extends Equatable {
  const ChatThreadState();

  @override
  List<Object> get props => [];
}

/// The initial state before any data is fetched.
final class ChatThreadInitial extends ChatThreadState {}

/// The state when data for the chat thread is being loaded.
/// The UI should show a loading indicator.
final class ChatThreadLoading extends ChatThreadState {}

/// The state when all necessary data for the chat thread has been successfully loaded.
/// It contains both the chat details and the list of messages.
final class ChatThreadLoaded extends ChatThreadState {
  final ChatEntity chat;
  final List<MessageEntity> messages;
  final bool isSending;

  const ChatThreadLoaded({
    required this.chat,
    required this.messages,
    this.isSending = false,
  });

  ChatThreadLoaded copyWith({
    ChatEntity? chat,
    List<MessageEntity>? messages,
    bool? isSending,
  }) {
    return ChatThreadLoaded(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object> get props => [chat, messages, isSending];
}

/// The state when an error occurs while fetching data for the thread.
final class ChatThreadError extends ChatThreadState {
  final String message;
  const ChatThreadError({required this.message});

  @override
  List<Object> get props => [message];
}

final class ChatThreadActionFailure extends ChatThreadState {
  final String message;
  const ChatThreadActionFailure(this.message);
  @override
  List<Object> get props => [message];
}

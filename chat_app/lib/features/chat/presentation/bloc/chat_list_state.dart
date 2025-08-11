part of 'chat_list_bloc.dart';

sealed class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object> get props => [];
}

final class ChatListInitial extends ChatListState {}

final class ChatListLoading extends ChatListState {}

final class ChatListLoaded extends ChatListState {
  final List<ChatEntity> chats;
  const ChatListLoaded({required this.chats});

  @override
  List<Object> get props => [chats];
}

// State for when an action (like delete) is successful.
// Can be used by BlocListener to show a SnackBar.
final class ChatListActionSuccess extends ChatListState {
  final String message;
  const ChatListActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class ChatListError extends ChatListState {
  final String message;
  const ChatListError({required this.message});

  @override
  List<Object> get props => [message];
}

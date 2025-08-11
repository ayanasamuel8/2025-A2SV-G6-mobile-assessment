import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/realtime_event.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/delete_chat_usecase.dart';
import '../../domain/usecases/get_chats_usecase.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatsUseCase _getChatsUseCase;
  final DeleteChatUseCase _deleteChatUseCase;
  StreamSubscription<RealtimeEvent>? _realtimeSubscription;

  ChatListBloc({
    required GetChatsUseCase getChatsUseCase,
    required DeleteChatUseCase deleteChatUseCase,
  }) : _getChatsUseCase = getChatsUseCase,
       _deleteChatUseCase = deleteChatUseCase,
       super(ChatListInitial()) {
    on<GetChatsListEvent>(_onGetChatsList);
    on<DeleteChatEvent>(_onDeleteChat);
    on<_NewMessageForListReceived>(_onNewMessageForListReceived);
    on<_ChatInListMarkedAsRead>(_onChatInListMarkedAsRead);
  }

  Future<void> _onGetChatsList(
    GetChatsListEvent event,
    Emitter<ChatListState> emit,
  ) async {
    emit(ChatListLoading());
    final result = await _getChatsUseCase();
    result.fold(
      (failure) => emit(ChatListError(message: failure.message)),
      (chats) => emit(ChatListLoaded(chats: chats)),
    );
  }

  Future<void> _onDeleteChat(
    DeleteChatEvent event,
    Emitter<ChatListState> emit,
  ) async {
    final result = await _deleteChatUseCase(event.chatId);
    result.fold((failure) => emit(ChatListError(message: failure.message)), (
      _,
    ) {
      emit(const ChatListActionSuccess('Chat deleted successfully'));
      add(GetChatsListEvent());
    });
  }

  void _onNewMessageForListReceived(
    _NewMessageForListReceived event,
    Emitter<ChatListState> emit,
  ) {
    final currentState = state;
    if (currentState is ChatListLoaded) {
      final updatedList = currentState.chats.map((chat) {
        if (chat.id == event.message.chatId) {
          return chat.copyWith(
            lastMessage: event.message.content,
            lastMessageTime: event.message.timestamp,
            unreadCount: chat.unreadCount + 1,
          );
        }
        return chat;
      }).toList();

      updatedList.sort((a, b) {
        final timeA = a.lastMessageTime ?? DateTime(1970);
        final timeB = b.lastMessageTime ?? DateTime(1970);
        return timeB.compareTo(timeA);
      });

      emit(ChatListLoaded(chats: updatedList));
    }
  }

  void _onChatInListMarkedAsRead(
    _ChatInListMarkedAsRead event,
    Emitter<ChatListState> emit,
  ) {
    final currentState = state;
    if (currentState is ChatListLoaded) {
      final updatedList = currentState.chats.map((chat) {
        if (chat.id == event.chatId) {
          return chat.copyWith(unreadCount: 0);
        }
        return chat;
      }).toList();
      emit(ChatListLoaded(chats: updatedList));
    }
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    return super.close();
  }
}

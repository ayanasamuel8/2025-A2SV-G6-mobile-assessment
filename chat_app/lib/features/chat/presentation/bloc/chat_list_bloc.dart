import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_entity.dart';
import '../../domain/usecases/delete_chat_usecase.dart';
import '../../domain/usecases/get_chats_usecase.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatsUseCase _getChatsUseCase;
  final DeleteChatUseCase _deleteChatUseCase;

  ChatListBloc({
    required GetChatsUseCase getChatsUseCase,
    required DeleteChatUseCase deleteChatUseCase,
  }) : _getChatsUseCase = getChatsUseCase,
       _deleteChatUseCase = deleteChatUseCase,
       super(ChatListInitial()) {
    on<GetChatsListEvent>(_onGetChatsList);
    on<DeleteChatEvent>(_onDeleteChat);
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
    // Optionally emit a loading state specific to the item being deleted
    final result = await _deleteChatUseCase(event.chatId);
    result.fold((failure) => emit(ChatListError(message: failure.message)), (
      _,
    ) {
      // On success, show a success message and then refresh the chat list.
      emit(const ChatListActionSuccess('Chat deleted successfully'));
      add(GetChatsListEvent()); // Trigger a refresh of the list
    });
  }
}

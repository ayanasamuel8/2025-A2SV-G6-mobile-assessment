import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/message_type.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/realtime_event.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_chat_by_id_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/initiate_chat_usecase.dart';

part 'chat_thread_event.dart';
part 'chat_thread_state.dart';

class ChatThreadBloc extends Bloc<ChatThreadEvent, ChatThreadState> {
  final GetMessagesUsecase _getMessagesUseCase;
  final GetChatByIdUsecase _getChatByIdUseCase;
  final InitiateChatUseCase _initiateChatUseCase;
  final ChatRepository _chatRepository;
  final AuthBloc _authBloc;

  StreamSubscription<RealtimeEvent>? _realtimeSubscription;

  ChatThreadBloc({
    required GetMessagesUsecase getMessagesUseCase,
    required GetChatByIdUsecase getChatByIdUseCase,
    required InitiateChatUseCase initiateChatUseCase,
    required ChatRepository chatRepository,
    required AuthBloc authBloc,
  }) : _getMessagesUseCase = getMessagesUseCase,
       _getChatByIdUseCase = getChatByIdUseCase,
       _initiateChatUseCase = initiateChatUseCase,
       _chatRepository = chatRepository,
       _authBloc = authBloc,
       super(ChatThreadInitial()) {
    on<FetchThreadDataEvent>(_onFetchThreadData);
    on<InitiateChatEvent>(_onInitiateChat);
    on<SendMessageEvent>(_onSendMessage);

    on<_NewMessageReceived>(_onNewMessageReceived);
    on<_ChatMarkedAsRead>(_onChatMarkedAsRead);
    on<_RealtimeErrorOccurred>(_onRealtimeErrorOccurred);

    _listenToRealtimeEvents();
  }

  void _listenToRealtimeEvents() {
    _realtimeSubscription = _chatRepository.getRealtimeEvents().listen((event) {
      switch (event) {
        case NewMessageEvent():
          add(_NewMessageReceived(event.message));
          break;
        case MessagesHaveBeenReadEvent():
          add(_ChatMarkedAsRead(event.chatId));
          break;
        case RealtimeErrorEvent():
          add(_RealtimeErrorOccurred(event.errorMessage));
          break;
        default:
          break;
      }
    });
  }

  // --- HANDLERS FOR PUBLIC EVENTS ---

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatThreadState> emit,
  ) async {
    final currentState = state;
    print('current state $currentState');
    if (currentState is ChatThreadLoaded) {
      emit(currentState.copyWith(isSending: true));
      _chatRepository.sendMessage(
        chatId: currentState.chat.id,
        content: event.content,
        type: event.type,
      );
    }
  }

  // --- HANDLERS FOR INTERNAL, REAL-TIME EVENTS ---

  void _onNewMessageReceived(
    _NewMessageReceived event,
    Emitter<ChatThreadState> emit,
  ) {
    final currentState = state;
    if (currentState is ChatThreadLoaded) {
      if (event.message.chatId == currentState.chat.id) {
        if (!currentState.messages.any(
          (m) => m.messageId == event.message.messageId,
        )) {
          final updatedMessages = List<MessageEntity>.from(
            currentState.messages,
          )..add(event.message);
          final authState = _authBloc.state;
          if (authState is Authenticated) {
            _chatRepository.markChatAsRead(currentState.chat.id);
          }
          emit(
            ChatThreadLoaded(
              chat: currentState.chat,
              messages: updatedMessages,
              isSending: false,
            ),
          );
        } else {
          emit(currentState.copyWith(isSending: false));
        }
      }
    }
  }

  void _onChatMarkedAsRead(
    _ChatMarkedAsRead event,
    Emitter<ChatThreadState> emit,
  ) {
    final currentState = state;
    final authState = _authBloc.state;
    if (currentState is ChatThreadLoaded && authState is Authenticated) {
      if (currentState.chat.id == event.chatId) {
        final updatedMessages = currentState.messages.map((message) {
          if (message.sender.id == authState.user?.id) {
            return message.copyWith(status: MessageStatus.read);
          }
          return message;
        }).toList();
        emit(
          ChatThreadLoaded(chat: currentState.chat, messages: updatedMessages),
        );
      }
    }
  }

  void _onRealtimeErrorOccurred(
    _RealtimeErrorOccurred event,
    Emitter<ChatThreadState> emit,
  ) {
    emit(ChatThreadActionFailure(event.message));
  }

  Future<void> _onFetchThreadData(
    FetchThreadDataEvent event,
    Emitter<ChatThreadState> emit,
  ) async {
    emit(ChatThreadLoading());

    final results = await Future.wait([
      _getChatByIdUseCase(event.chatId),
      _getMessagesUseCase(event.chatId),
    ]);

    final chatResult = results[0];
    final messagesResult = results[1];

    chatResult.fold(
      (failure) => emit(ChatThreadError(message: failure.message)),
      (chat) {
        messagesResult.fold(
          (failure) => emit(ChatThreadError(message: failure.message)),
          (messages) => emit(
            ChatThreadLoaded(
              chat: chat as ChatEntity,
              messages: messages as List<MessageEntity>,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onInitiateChat(
    InitiateChatEvent event,
    Emitter<ChatThreadState> emit,
  ) async {
    emit(ChatThreadLoading());
    final result = await _initiateChatUseCase(event.receiverId);

    result.fold((failure) => emit(ChatThreadError(message: failure.message)), (
      newChat,
    ) {
      emit(ChatThreadLoaded(chat: newChat, messages: const []));
    });
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    return super.close();
  }
}

import 'package:dartz/dartz.dart';

import '../../../../core/constants/message_type.dart';
import '../../../../core/error/failure.dart';
import '../../data/models/realtime_event.dart';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  // --- HTTP Methods ---
  Future<Either<Failure, List<ChatEntity>>> getChats();
  Future<Either<Failure, ChatEntity>> getChatById(String chatId);
  Future<Either<Failure, List<MessageEntity>>> getMessages(String chatId);
  Future<Either<Failure, ChatEntity>> initiateChat(String receiverId);
  Future<Either<Failure, void>> deleteChat(String chatId);

  // --- Socket.IO Methods ---
  Future<void> connect();
  void disconnect();
  Stream<RealtimeEvent> getRealtimeEvents();
  void sendMessage({
    required String chatId,
    required String content,
    required MessageType type,
  });
  void markChatAsRead(String chatId);
}

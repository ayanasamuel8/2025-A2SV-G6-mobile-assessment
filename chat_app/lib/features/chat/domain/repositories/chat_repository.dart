import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatEntity>>> getChats(String token);
  Future<Either<Failure, ChatEntity>> getChatById(String chatId, String token);
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String chatId,
    String token,
  );
  Future<Either<Failure, ChatEntity>> initiateChat(
    String receiverId,
    String token,
  );
  Future<Either<Failure, void>> deleteChat(String chatId, String token);
}

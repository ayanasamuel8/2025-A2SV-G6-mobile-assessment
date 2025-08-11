import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUsecase {
  final ChatRepository repository;

  GetMessagesUsecase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call(String chatId) {
    return repository.getMessages(chatId);
  }
}

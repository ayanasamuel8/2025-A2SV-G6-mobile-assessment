import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatByIdUsecase {
  final ChatRepository repository;

  GetChatByIdUsecase(this.repository);

  Future<Either<Failure, ChatEntity>> call(String chatId) {
    return repository.getChatById(chatId);
  }
}

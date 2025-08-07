import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/chat_repository.dart';

class DeleteChatUseCase {
  final ChatRepository repository;

  DeleteChatUseCase(this.repository);

  Future<Either<Failure, void>> call(String chatId, String token) {
    return repository.deleteChat(chatId, token);
  }
}

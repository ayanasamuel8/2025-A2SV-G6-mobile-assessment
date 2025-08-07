import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class InitiateChatUseCase {
  final ChatRepository repository;

  InitiateChatUseCase(this.repository);

  Future<Either<Failure, ChatEntity>> call(String receiverId, String token) {
    return repository.initiateChat(receiverId, token);
  }
}

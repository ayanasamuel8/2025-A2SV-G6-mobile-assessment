import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatsUseCase {
  final ChatRepository repository;

  GetChatsUseCase(this.repository);

  Future<Either<Failure, List<ChatEntity>>> call() {
    print('GetChatsUseCase called');
    final response = repository.getChats();
    print('GetChatsUseCase response: $response');
    return response;
  }
}

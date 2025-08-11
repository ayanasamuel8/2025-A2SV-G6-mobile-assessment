import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repository/auth_repository.dart';

class GetMeUseCase {
  final AuthRepository repository;

  GetMeUseCase(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.getMe();
  }
}

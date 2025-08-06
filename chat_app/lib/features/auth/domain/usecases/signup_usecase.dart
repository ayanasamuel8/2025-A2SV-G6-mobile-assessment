import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repository/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String name,
    String email,
    String password,
  ) {
    return repository.register(name, email, password);
  }
}

// import '../entities/user.dart';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login(String email, String password);
  Future<Either<Failure, void>> register(
    String name,
    String email,
    String password,
  );
  // Future<User> getMe(String token);
  Future<void> logout();
}

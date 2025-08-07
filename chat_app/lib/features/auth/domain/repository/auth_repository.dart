import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login(String email, String password);
  Future<Either<Failure, void>> register(
    String name,
    String email,
    String password,
  );
  Future<Either<Failure, User>> getMe();
  Future<bool> isAuthenticated();
  Future<void> logout();
}

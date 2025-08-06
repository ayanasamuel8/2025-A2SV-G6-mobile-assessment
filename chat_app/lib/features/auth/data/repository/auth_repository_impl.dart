import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, void>> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    return response.fold((failure) => Left(failure), (token) async {
      await localDataSource.saveToken(token);
      return const Right(null);
    });
  }

  @override
  Future<Either<Failure, void>> register(
    String name,
    String email,
    String password,
  ) {
    return remoteDataSource.register(name, email, password);
  }

  @override
  Future<void> logout() async {
    await localDataSource.deleteToken();
  }
}

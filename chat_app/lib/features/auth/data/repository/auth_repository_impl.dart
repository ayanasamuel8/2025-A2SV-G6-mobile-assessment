import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      final response = await remoteDataSource.login(email, password);
      return response.fold((failure) => Left(failure), (token) async {
        await localDataSource.saveToken(token);
        return const Right(null);
      });
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, void>> register(
    String name,
    String email,
    String password,
  ) async {
    if (await networkInfo.isConnected) {
      return remoteDataSource.register(name, email, password);
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.deleteToken();
  }
}

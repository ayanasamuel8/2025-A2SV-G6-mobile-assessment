import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repository/auth_repository.dart';

class SearchUsersUseCase {
  final AuthRepository _repository;

  SearchUsersUseCase(this._repository);

  Future<Either<Failure, List<User>>> call(String query) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }

    return _repository.searchUsers(query);
  }
}

import '../repository/auth_repository.dart';

class CheckAuthenticatedUseCase {
  final AuthRepository repository;

  CheckAuthenticatedUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isAuthenticated();
  }
}

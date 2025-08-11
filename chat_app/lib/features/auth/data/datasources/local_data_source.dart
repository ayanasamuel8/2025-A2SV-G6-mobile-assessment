import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);

  Future<String?> getToken();

  Future<void> deleteToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl({required this.storage});

  @override
  Future<void> saveToken(String token) async {
    await storage.write(key: 'access_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await storage.read(key: 'access_token');
  }

  @override
  Future<void> deleteToken() async {
    await storage.delete(key: 'access_token');
  }
}

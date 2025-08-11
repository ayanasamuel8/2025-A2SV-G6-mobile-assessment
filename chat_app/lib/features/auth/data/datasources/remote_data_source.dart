import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../models/user.dart';

abstract class RemoteDataSource {
  Future<Either<Failure, String>> login(String email, String password);
  Future<Either<Failure, void>> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  );
  Future<Either<Failure, UserModel>> getMe(String token);
  Future<List<UserModel>> searchUsers(String query);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final String _baseUrl = 'https://chat-backend-efxf.onrender.com/api';
  final http.Client client;

  RemoteDataSourceImpl({required this.client});

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    print('Login called with email: $email');
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Right(jsonDecode(response.body)['data']['access_token']);
    } else if (response.statusCode == 401) {
      return const Left(UnauthorizedFailure('Invalid email or password'));
    } else {
      final message = jsonDecode(response.body)['message'] ?? '';
      return Left(ServerFailure('Login failed, please try again. $message'));
    }
  }

  @override
  Future<Either<Failure, void>> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    print('Password length: ${password.length}');
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode == 201) {
      return const Right(null);
    } else {
      final message = jsonDecode(response.body)['message'] ?? '';
      return Left(
        ServerFailure('Registration failed, please try again. $message'),
      );
    }
  }

  @override
  Future<Either<Failure, UserModel>> getMe(String token) async {
    print('Fetching user with token: $token');
    final response = await client.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token ',
      },
    );

    if (response.statusCode == 200) {
      final user = UserModel.fromJson(jsonDecode(response.body)['data']);
      return Right(user);
    } else {
      return const Left(ServerFailure('Failed to fetch user'));
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    final url = Uri.parse('$_baseUrl/auth/search?name=$query');

    final response = await client.get(url);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } catch (e) {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }
}

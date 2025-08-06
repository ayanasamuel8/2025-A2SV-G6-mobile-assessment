import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/failure.dart';

abstract class RemoteDataSource {
  Future<Either<Failure, String>> login(String email, String password);
  Future<Either<Failure, void>> register(
    String name,
    String email,
    String password,
  );
  // Future<Either<Failure, Map<String, dynamic>>> getMe(String token);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final String _baseUrl =
      'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v3';
  final http.Client client;

  RemoteDataSourceImpl({required this.client});

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return Right(jsonDecode(response.body)['data']['access_token']);
    } else {
      return const Left(ServerFailure('Login failed'));
    }
  }

  @override
  Future<Either<Failure, void>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return const Right(null);
    } else {
      return const Left(ServerFailure('Registration failed'));
    }
  }

  /// future integration!
  // @override
  // Future<Either<Failure, Map<String, dynamic>>> getMe(String token) async {
  //   final response = await client.get(
  //     Uri.parse('$_baseUrl/auth/user'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'authorization': 'Bearer $token ',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     return Right(jsonDecode(response.body)['data']);
  //   } else {
  //     return const Left(ServerFailure('Failed to fetch user'));
  //   }
  // }
}

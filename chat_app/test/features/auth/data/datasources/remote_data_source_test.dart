import 'dart:convert';

import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/data/datasources/remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late RemoteDataSource dataSource;
  late MockHttpClient mockHttpClient;
  const tBaseUrl = 'https://g5-flutter-learning-path-be.onrender.com/api/v2';

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = RemoteDataSource(mockHttpClient);
    registerFallbackValue(Uri.parse('$tBaseUrl/auth/login'));
  });

  group('login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password';
    const tToken = 'sample_token';
    final tLoginUrl = Uri.parse('$tBaseUrl/auth/login');
    final tHeaders = {'Content-Type': 'application/json'};
    final tBody = jsonEncode({'email': tEmail, 'password': tPassword});

    test(
      'should return a token string when the response code is 200 (success)',
      () async {
        // arrange
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'data': {'access_token': tToken},
            }),
            200,
          ),
        );

        // act
        final result = await dataSource.login(tEmail, tPassword);

        // assert
        expect(result, const Right(tToken));
        verify(
          () => mockHttpClient.post(tLoginUrl, headers: tHeaders, body: tBody),
        ).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      },
    );

    test(
      'should return a ServerFailure when the response code is not 200',
      () async {
        // arrange
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response('Login failed', 401));

        // act
        final result = await dataSource.login(tEmail, tPassword);

        // assert
        expect(result, const Left(ServerFailure('Login failed')));
        verify(
          () => mockHttpClient.post(tLoginUrl, headers: tHeaders, body: tBody),
        ).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      },
    );
  });

  group('register', () {
    const tName = 'Test User';
    const tEmail = 'test@example.com';
    const tPassword = 'password';
    final tRegisterUrl = Uri.parse('$tBaseUrl/auth/register');
    final tHeaders = {'Content-Type': 'application/json'};
    final tBody = jsonEncode({
      'name': tName,
      'email': tEmail,
      'password': tPassword,
    });

    test(
      'should return Right(null) when the response code is 201 (success)',
      () async {
        // arrange
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response('Success', 201));

        // act
        final result = await dataSource.register(tName, tEmail, tPassword);

        // assert
        expect(result, const Right(null));
        verify(
          () =>
              mockHttpClient.post(tRegisterUrl, headers: tHeaders, body: tBody),
        ).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      },
    );

    test(
      'should return a ServerFailure when the response code is not 201',
      () async {
        // arrange
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response('Registration failed', 400));

        // act
        final result = await dataSource.register(tName, tEmail, tPassword);

        // assert
        expect(result, const Left(ServerFailure('Registration failed')));
        verify(
          () =>
              mockHttpClient.post(tRegisterUrl, headers: tHeaders, body: tBody),
        ).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      },
    );
  });
}

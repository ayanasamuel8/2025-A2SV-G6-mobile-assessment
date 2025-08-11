import 'dart:convert';

import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/data/datasources/remote_data_source.dart';
import 'package:chat_app/features/auth/data/models/user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late RemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;
  const tBaseUrl = 'https://chat-backend-efxf.onrender.com/api';

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = RemoteDataSourceImpl(client: mockHttpClient);
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
      'should return a token string when the response code is 200 or 201 (success)',
      () async {
        for (final statusCode in [200, 201]) {
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
              statusCode,
            ),
          );

          // act
          final result = await dataSource.login(tEmail, tPassword);

          // assert
          expect(result, const Right(tToken));
          verify(
            () =>
                mockHttpClient.post(tLoginUrl, headers: tHeaders, body: tBody),
          ).called(1);
          verifyNoMoreInteractions(mockHttpClient);
        }
      },
    );

    test(
      'should return an UnauthorizedFailure when the response code is 401',
      () async {
        // arrange
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response('Unauthorized', 401));

        // act
        final result = await dataSource.login(tEmail, tPassword);

        // assert
        expect(
          result,
          const Left(UnauthorizedFailure('Invalid email or password')),
        );
        verify(
          () => mockHttpClient.post(tLoginUrl, headers: tHeaders, body: tBody),
        ).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      },
    );

    test(
      'should return a ServerFailure when the response code is not 200, 201, or 401',
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
            jsonEncode({'message': 'Something went wrong'}),
            500,
          ),
        );

        // act
        final result = await dataSource.login(tEmail, tPassword);

        // assert
        expect(
          result,
          const Left(
            ServerFailure(
              'Login failed, please try again. Something went wrong',
            ),
          ),
        );
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
    const tConfirmPassword = 'password';
    final tRegisterUrl = Uri.parse('$tBaseUrl/auth/register');
    final tHeaders = {'Content-Type': 'application/json'};
    final tBody = jsonEncode({
      'name': tName,
      'email': tEmail,
      'password': tPassword,
      'confirmPassword': tConfirmPassword,
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
        final result = await dataSource.register(
          tName,
          tEmail,
          tPassword,
          tConfirmPassword,
        );

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
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'message': 'Email already exists'}),
            400,
          ),
        );

        // act
        final result = await dataSource.register(
          tName,
          tEmail,
          tPassword,
          tConfirmPassword,
        );

        // assert
        expect(
          result,
          const Left(
            ServerFailure(
              'Registration failed, please try again. Email already exists',
            ),
          ),
        );
        verify(
          () =>
              mockHttpClient.post(tRegisterUrl, headers: tHeaders, body: tBody),
        ).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      },
    );
  });

  group('getMe', () {
    const tToken = 'sample_token';
    final tUserUrl = Uri.parse('$tBaseUrl/auth/me');
    final tHeaders = {
      'Content-Type': 'application/json',
      'authorization': 'Bearer $tToken ',
    };
    final tUserMap = {
      '_id': '1',
      'name': 'Test User',
      'email': 'test@test.com',
    };

    test(
      'should return user data when the response code is 200 (success)',
      () async {
        // arrange
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode({'data': tUserMap}), 200),
        );

        // act
        final result = await dataSource.getMe(tToken);

        // assert
        expect(result, Right<Failure, UserModel>(UserModel.fromJson(tUserMap)));
        verify(() => mockHttpClient.get(tUserUrl, headers: tHeaders)).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      },
    );

    test(
      'should return a ServerFailure when the response code is not 200',
      () async {
        // arrange
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        // act
        final result = await dataSource.getMe(tToken);

        // assert
        expect(result, const Left(ServerFailure('Failed to fetch user')));
        verify(() => mockHttpClient.get(tUserUrl, headers: tHeaders)).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      },
    );
  });
}

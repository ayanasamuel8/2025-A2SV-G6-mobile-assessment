import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/core/network/network_info.dart';
import 'package:chat_app/features/auth/data/datasources/local_data_source.dart';
import 'package:chat_app/features/auth/data/datasources/remote_data_source.dart';
import 'package:chat_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock implements RemoteDataSource {}

class MockLocalDataSource extends Mock implements LocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('login', () {
    const tEmail = 'test@test.com';
    const tPassword = 'password';
    const tToken = 'sample_token';
    final tServerFailure = const ServerFailure('Server Error');

    runTestsOnline(() {
      test(
        'should call remoteDataSource.login and localDataSource.saveToken on success',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.login(any(), any()),
          ).thenAnswer((_) async => const Right(tToken));
          when(
            () => mockLocalDataSource.saveToken(any()),
          ).thenAnswer((_) async => Future.value());

          // act
          final result = await repository.login(tEmail, tPassword);

          // assert
          expect(result, const Right(null));
          verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
          verify(() => mockLocalDataSource.saveToken(tToken)).called(1);
          verifyNoMoreInteractions(mockRemoteDataSource);
          verifyNoMoreInteractions(mockLocalDataSource);
        },
      );

      test(
        'should return a Failure when remoteDataSource.login fails',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.login(any(), any()),
          ).thenAnswer((_) async => Left(tServerFailure));

          // act
          final result = await repository.login(tEmail, tPassword);

          // assert
          expect(result, Left(tServerFailure));
          verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
          verifyZeroInteractions(mockLocalDataSource);
        },
      );
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.login(tEmail, tPassword);

        // assert
        expect(result, const Left(NetworkFailure('No Internet Connection')));
        verifyZeroInteractions(mockRemoteDataSource);
        verifyZeroInteractions(mockLocalDataSource);
      });
    });
  });

  group('register', () {
    const tName = 'Test User';
    const tEmail = 'test@test.com';
    const tPassword = 'password';
    final tServerFailure = const ServerFailure('Server Error');

    runTestsOnline(() {
      test(
        'should call remoteDataSource.register and return success',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.register(any(), any(), any()),
          ).thenAnswer((_) async => const Right(null));

          // act
          final result = await repository.register(tName, tEmail, tPassword);

          // assert
          expect(result, const Right(null));
          verify(
            () => mockRemoteDataSource.register(tName, tEmail, tPassword),
          ).called(1);
          verifyNoMoreInteractions(mockRemoteDataSource);
          verifyZeroInteractions(mockLocalDataSource);
        },
      );

      test(
        'should return a Failure when remoteDataSource.register fails',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.register(any(), any(), any()),
          ).thenAnswer((_) async => Left(tServerFailure));

          // act
          final result = await repository.register(tName, tEmail, tPassword);

          // assert
          expect(result, Left(tServerFailure));
          verify(
            () => mockRemoteDataSource.register(tName, tEmail, tPassword),
          ).called(1);
          verifyZeroInteractions(mockLocalDataSource);
        },
      );
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.register(tName, tEmail, tPassword);

        // assert
        expect(result, const Left(NetworkFailure('No Internet Connection')));
        verifyZeroInteractions(mockRemoteDataSource);
        verifyZeroInteractions(mockLocalDataSource);
      });
    });
  });

  group('logout', () {
    test('should call localDataSource.deleteToken', () async {
      // arrange
      when(
        () => mockLocalDataSource.deleteToken(),
      ).thenAnswer((_) async => Future.value());
      // act
      await repository.logout();

      // assert
      verify(() => mockLocalDataSource.deleteToken()).called(1);
      verifyNoMoreInteractions(mockLocalDataSource);
      verifyZeroInteractions(mockRemoteDataSource);
    });
  });
}

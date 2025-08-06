import 'package:chat_app/features/auth/data/datasources/local_data_source.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late LocalDataSource localDataSource;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    localDataSource = LocalDataSource(mockStorage);
  });

  group('LocalDataSource', () {
    const tToken = 'test_token';
    const tKey = 'access_token';

    group('saveToken', () {
      test(
        'should call storage.write with the correct key and value',
        () async {
          // Arrange
          when(
            () => mockStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          ).thenAnswer((_) async => Future.value());

          // Act
          await localDataSource.saveToken(tToken);

          // Assert
          verify(() => mockStorage.write(key: tKey, value: tToken)).called(1);
          verifyNoMoreInteractions(mockStorage);
        },
      );
    });

    group('getToken', () {
      test(
        'should call storage.read and return the token when it exists',
        () async {
          // Arrange
          when(
            () => mockStorage.read(key: any(named: 'key')),
          ).thenAnswer((_) async => tToken);

          // Act
          final result = await localDataSource.getToken();

          // Assert
          expect(result, tToken);
          verify(() => mockStorage.read(key: tKey)).called(1);
          verifyNoMoreInteractions(mockStorage);
        },
      );

      test('should return null when the token does not exist', () async {
        // Arrange
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => null);

        // Act
        final result = await localDataSource.getToken();

        // Assert
        expect(result, isNull);
        verify(() => mockStorage.read(key: tKey)).called(1);
        verifyNoMoreInteractions(mockStorage);
      });
    });

    group('deleteToken', () {
      test('should call storage.delete with the correct key', () async {
        // Arrange
        when(
          () => mockStorage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async => Future.value());

        // Act
        await localDataSource.deleteToken();

        // Assert
        verify(() => mockStorage.delete(key: tKey)).called(1);
        verifyNoMoreInteractions(mockStorage);
      });
    });
  });
}

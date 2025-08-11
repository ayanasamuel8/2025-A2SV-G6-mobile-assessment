import 'dart:convert';

import 'package:chat_app/core/error/exception.dart';
import 'package:chat_app/features/auth/data/models/user.dart';
import 'package:chat_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chat_app/features/chat/data/models/chat_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late ChatRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = ChatRemoteDataSourceImpl(client: mockHttpClient);
    registerFallbackValue(Uri.parse(''));
  });

  const tBaseUrl = 'https://chat-backend-efxf.onrender.com/api';
  const tToken = 'sample_token';
  const tChatId = 'chat1';
  const tReceiverId = 'user2';

  const tUserModel1 = UserModel(
    id: 'user1',
    name: 'User One',
    email: 'user1@example.com',
  );
  const tUserModel2 = UserModel(
    id: 'user2',
    name: 'User Two',
    email: 'user2@example.com',
  );

  const tChatModel = ChatModel(
    id: 'chat1',
    user1: tUserModel1,
    user2: tUserModel2,
  );

  final tChatList = [tChatModel];

  final tHeaders = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $tToken',
  };

  void setUpMockHttpClientSuccess({
    required String method,
    required Uri url,
    required String responseBody,
    required int statusCode,
    Map<String, String>? headers,
    dynamic body,
  }) {
    switch (method) {
      case 'GET':
        when(
          () => mockHttpClient.get(url, headers: headers),
        ).thenAnswer((_) async => http.Response(responseBody, statusCode));
        break;
      case 'POST':
        when(
          () => mockHttpClient.post(url, headers: headers, body: body),
        ).thenAnswer((_) async => http.Response(responseBody, statusCode));
        break;
      case 'DELETE':
        when(
          () => mockHttpClient.delete(url, headers: headers),
        ).thenAnswer((_) async => http.Response(responseBody, statusCode));
        break;
    }
  }

  void setUpMockHttpClientFailure({
    required String method,
    required Uri url,
    required int statusCode,
    Map<String, String>? headers,
    dynamic body,
  }) {
    switch (method) {
      case 'GET':
        when(() => mockHttpClient.get(url, headers: headers)).thenAnswer(
          (_) async => http.Response('Something went wrong', statusCode),
        );
        break;
      case 'POST':
        when(
          () => mockHttpClient.post(url, headers: headers, body: body),
        ).thenAnswer(
          (_) async => http.Response('Something went wrong', statusCode),
        );
        break;
      case 'DELETE':
        when(() => mockHttpClient.delete(url, headers: headers)).thenAnswer(
          (_) async => http.Response('Something went wrong', statusCode),
        );
        break;
    }
  }

  group('getChats', () {
    final tChatListJson = json.encode(
      tChatList.map((chat) => chat.toJson()).toList(),
    );
    final url = Uri.parse('$tBaseUrl/chats');

    test(
      'should perform a GET request on a URL with application/json header',
      () async {
        // arrange
        setUpMockHttpClientSuccess(
          method: 'GET',
          url: url,
          responseBody: tChatListJson,
          statusCode: 200,
          headers: tHeaders,
        );
        // act
        await dataSource.getChats(tToken);
        // assert
        verify(() => mockHttpClient.get(url, headers: tHeaders)).called(1);
      },
    );

    test(
      'should return List<ChatModel> when the response code is 200 (success)',
      () async {
        // arrange
        setUpMockHttpClientSuccess(
          method: 'GET',
          url: url,
          responseBody: tChatListJson,
          statusCode: 200,
          headers: tHeaders,
        );
        // act
        final result = await dataSource.getChats(tToken);
        // assert
        expect(result, equals(tChatList));
      },
    );

    test(
      'should throw a ServerException when the response code is not 200',
      () async {
        // arrange
        setUpMockHttpClientFailure(
          method: 'GET',
          url: url,
          statusCode: 404,
          headers: tHeaders,
        );
        // act
        final call = dataSource.getChats;
        // assert
        expect(() => call(tToken), throwsA(isA<ServerException>()));
      },
    );
  });

  group('getChatById', () {
    final tChatJson = json.encode(tChatModel.toJson());
    final url = Uri.parse('$tBaseUrl/chats/$tChatId');

    test('should perform a GET request for a specific chat', () async {
      // arrange
      setUpMockHttpClientSuccess(
        method: 'GET',
        url: url,
        responseBody: tChatJson,
        statusCode: 200,
        headers: tHeaders,
      );
      // act
      await dataSource.getChatById(tChatId, tToken);
      // assert
      verify(() => mockHttpClient.get(url, headers: tHeaders)).called(1);
    });

    test('should return ChatModel when the response code is 200', () async {
      // arrange
      setUpMockHttpClientSuccess(
        method: 'GET',
        url: url,
        responseBody: tChatJson,
        statusCode: 200,
        headers: tHeaders,
      );
      // act
      final result = await dataSource.getChatById(tChatId, tToken);
      // assert
      expect(result, equals(tChatModel));
    });

    test(
      'should throw ServerException when response code is not 200',
      () async {
        // arrange
        setUpMockHttpClientFailure(
          method: 'GET',
          url: url,
          statusCode: 404,
          headers: tHeaders,
        );
        // act
        final call = dataSource.getChatById;
        // assert
        expect(() => call(tChatId, tToken), throwsA(isA<ServerException>()));
      },
    );
  });

  group('getMessages', () {
    final url = Uri.parse('$tBaseUrl/chats/$tChatId/messages');
    test(
      'should throw ServerException when response code is not 200',
      () async {
        // arrange
        setUpMockHttpClientFailure(
          method: 'GET',
          url: url,
          statusCode: 500,
          headers: tHeaders,
        );
        // act
        final call = dataSource.getMessages;
        // assert
        expect(() => call(tChatId, tToken), throwsA(isA<ServerException>()));
      },
    );
  });

  group('initiateChat', () {
    final tChatJson = json.encode(tChatModel.toJson());
    final url = Uri.parse('$tBaseUrl/chats');
    final tBody = json.encode({'userId': tReceiverId});

    test('should perform a POST request to initiate a chat', () async {
      // arrange
      setUpMockHttpClientSuccess(
        method: 'POST',
        url: url,
        responseBody: tChatJson,
        statusCode: 201,
        headers: tHeaders,
        body: tBody,
      );
      // act
      await dataSource.initiateChat(tReceiverId, tToken);
      // assert
      verify(
        () => mockHttpClient.post(url, headers: tHeaders, body: tBody),
      ).called(1);
    });

    test('should return ChatModel when response code is 201', () async {
      // arrange
      setUpMockHttpClientSuccess(
        method: 'POST',
        url: url,
        responseBody: tChatJson,
        statusCode: 201,
        headers: tHeaders,
        body: tBody,
      );
      // act
      final result = await dataSource.initiateChat(tReceiverId, tToken);
      // assert
      expect(result, equals(tChatModel));
    });

    test(
      'should throw ServerException when response code is not 201',
      () async {
        // arrange
        setUpMockHttpClientFailure(
          method: 'POST',
          url: url,
          statusCode: 400,
          headers: tHeaders,
          body: tBody,
        );
        // act
        final call = dataSource.initiateChat;
        // assert
        expect(
          () => call(tReceiverId, tToken),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });

  group('deleteChat', () {
    final url = Uri.parse('$tBaseUrl/chats/$tChatId');

    test('should perform a DELETE request to delete a chat', () async {
      // arrange
      setUpMockHttpClientSuccess(
        method: 'DELETE',
        url: url,
        responseBody: '',
        statusCode: 204,
        headers: tHeaders,
      );
      // act
      await dataSource.deleteChat(tChatId, tToken);
      // assert
      verify(() => mockHttpClient.delete(url, headers: tHeaders)).called(1);
    });

    test('should complete successfully when response code is 204', () async {
      // arrange
      setUpMockHttpClientSuccess(
        method: 'DELETE',
        url: url,
        responseBody: '',
        statusCode: 204,
        headers: tHeaders,
      );
      // act
      final call = dataSource.deleteChat(tChatId, tToken);
      // assert
      expect(call, completes);
    });

    test(
      'should throw ServerException when response code is not 204',
      () async {
        // arrange
        setUpMockHttpClientFailure(
          method: 'DELETE',
          url: url,
          statusCode: 404,
          headers: tHeaders,
        );
        // act
        final call = dataSource.deleteChat;
        // assert
        expect(() => call(tChatId, tToken), throwsA(isA<ServerException>()));
      },
    );
  });
}

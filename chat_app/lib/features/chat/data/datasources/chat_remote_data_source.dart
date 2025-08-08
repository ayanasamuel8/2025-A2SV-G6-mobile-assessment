import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exception.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> getChats(String token);
  Future<ChatModel> getChatById(String chatId, String token);
  Future<List<MessageModel>> getMessages(String chatId, String token);
  Future<ChatModel> initiateChat(String receiverId, String token);
  Future<void> deleteChat(String chatId, String token);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final String _baseUrl =
      'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v3';

  ChatRemoteDataSourceImpl({required this.client});

  @override
  Future<void> deleteChat(String chatId, String token) async {
    final response = await client.delete(
      Uri.parse('$_baseUrl/chats/$chatId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw ServerException();
    }
  }

  @override
  Future<ChatModel> getChatById(String chatId, String token) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/chats/$chatId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return ChatModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<ChatModel>> getChats(String token) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/chats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChatModel.fromJson(json)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String chatId, String token) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/chats/$chatId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<ChatModel> initiateChat(String receiverId, String token) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/chats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'userId': receiverId}),
    );

    if (response.statusCode == 201) {
      return ChatModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}

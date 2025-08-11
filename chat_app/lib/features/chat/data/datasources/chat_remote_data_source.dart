import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/constants/message_type.dart';
import '../../../../core/error/exception.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/realtime_event.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> getChats(String token);
  Future<ChatModel> getChatById(String chatId, String token);
  Future<List<MessageModel>> getMessages(String chatId, String token);
  Future<ChatModel> initiateChat(String receiverId, String token);
  Future<void> deleteChat(String chatId, String token);
  void connect(String token);
  void disconnect();
  Stream<RealtimeEvent> getRealtimeEvents();
  void sendMessage({
    required String chatId,
    required String content,
    required MessageType type,
  });
  void markChatAsRead(String chatId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  io.Socket? _socket;
  final StreamController<RealtimeEvent> _eventStreamController =
      StreamController.broadcast();
  final http.Client client;
  final String _baseUrl = 'https://chat-backend-efxf.onrender.com/api';
  final String _socketUrl = 'https://chat-backend-efxf.onrender.com';

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
    print('ChatRemoteDataSourceImpl.getChats called $token');
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
      final chatModel = ChatModel.fromJson(json.decode(response.body));
      log(
        "++++++=================================================" +
            chatModel.toString(),
      );
      return chatModel;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<void> connect(String token) async {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(
      _socketUrl,
      io.OptionBuilder().setTransports(<String>['websocket']).setAuth({
        'token': token,
      }).build(),
    );

    _socket!.onConnect((_) {
      print('Socket connected');
    });

    _socket!.onDisconnect((_) => print('Socket disconnected'));

    _socket!.onConnectError((err) => print('Socket connect error: $err'));

    _registerSocketListeners();
  }

  void _registerSocketListeners() {
    _socket!.on('message:received', (data) {
      try {
        final message = MessageModel.fromJson(data);
        _eventStreamController.add(NewMessageEvent(message));

        // IMPORTANT: Immediately acknowledge delivery back to the server.
        _socket!.emit('message:delivered_ack', {
          'messageId': message.messageId,
          'chatId': message.chatId,
        });
      } catch (e) {
        _eventStreamController.add(
          RealtimeErrorEvent('Failed to parse received message: $e'),
        );
      }
    });

    _socket!.on('message:delivered', (data) {
      try {
        final message = MessageModel.fromJson(data);
        _eventStreamController.add(NewMessageEvent(message));
      } catch (e) {
        _eventStreamController.add(
          RealtimeErrorEvent('Failed to parse sent confirmation: $e'),
        );
      }
    });

    _socket!.on('messages:were_read', (data) {
      final chatId = data['chatId'] as String;
      _eventStreamController.add(MessagesHaveBeenReadEvent(chatId));
    });

    _socket!.on(
      'error',
      (data) => _eventStreamController.add(RealtimeErrorEvent(data.toString())),
    );
    _socket!.on(
      'exception',
      (data) => _eventStreamController.add(RealtimeErrorEvent(data.toString())),
    );
  }

  @override
  Stream<RealtimeEvent> getRealtimeEvents() {
    return _eventStreamController.stream;
  }

  @override
  void sendMessage({
    required String chatId,
    required String content,
    required MessageType type,
  }) {
    if (_socket?.connected != true) {
      _eventStreamController.add(
        RealtimeErrorEvent('Cannot send message: Not connected.'),
      );
      return;
    }
    _socket!.emit('message:send', {
      'chatId': chatId,
      'content': content,
      'type': type.toString(),
    });
  }

  @override
  void markChatAsRead(String chatId) {
    _socket?.emit('chat:read', {'chatId': chatId});
  }

  @override
  void disconnect() {
    _socket?.dispose();
    _eventStreamController.close();
  }
}

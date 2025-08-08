import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/shared_prefrences_key.dart';
import '../../../../core/error/exception.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatLocalDataSource {
  /// Gets the cached [List<ChatModel>] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<List<ChatModel>> getLastChats();

  /// Caches a [List<ChatModel>] to the local storage.
  Future<void> cacheChats(List<ChatModel> chatsToCache);

  /// Gets the cached [ChatModel] for a given [chatId].
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<ChatModel> getLastChatById(String chatId);

  /// Caches a single [ChatModel].
  Future<void> cacheChat(ChatModel chatToCache);

  /// Gets the cached [List<MessageModel>] for a given [chatId].
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<List<MessageModel>> getLastMessages(String chatId);

  /// Caches a [List<MessageModel>] for a given [chatId].
  Future<void> cacheMessages(String chatId, List<MessageModel> messagesToCache);

  /// Clears the cache for a specific chat and its messages.
  Future<void> clearCacheForChat(String chatId);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final SharedPreferences sharedPreferences;

  ChatLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheChats(List<ChatModel> chatsToCache) {
    final List<String> jsonList = chatsToCache
        .map((chat) => json.encode(chat.toJson()))
        .toList();
    return sharedPreferences.setStringList(cachedChatsList, jsonList);
  }

  @override
  Future<List<ChatModel>> getLastChats() {
    final jsonList = sharedPreferences.getStringList(cachedChatsList);
    if (jsonList != null) {
      final chats = jsonList
          .map((json) => ChatModel.fromJson(jsonDecode(json)))
          .toList();
      return Future.value(chats);
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheChat(ChatModel chatToCache) {
    return sharedPreferences.setString(
      '$cachedChatPrefix${chatToCache.id}',
      json.encode(chatToCache.toJson()),
    );
  }

  @override
  Future<ChatModel> getLastChatById(String chatId) {
    final jsonString = sharedPreferences.getString('$cachedChatPrefix$chatId');
    if (jsonString != null) {
      return Future.value(ChatModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheMessages(
    String chatId,
    List<MessageModel> messagesToCache,
  ) {
    final List<String> jsonList = messagesToCache
        .map((message) => json.encode(message.toJson()))
        .toList();
    return sharedPreferences.setStringList(
      '$cachedMessagesPrefix$chatId',
      jsonList,
    );
  }

  @override
  Future<List<MessageModel>> getLastMessages(String chatId) {
    final jsonList = sharedPreferences.getStringList(
      '$cachedMessagesPrefix$chatId',
    );
    if (jsonList != null) {
      final messages = jsonList
          .map((json) => MessageModel.fromJson(jsonDecode(json)))
          .toList();
      return Future.value(messages);
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> clearCacheForChat(String chatId) async {
    await sharedPreferences.remove('$cachedChatPrefix$chatId');
    await sharedPreferences.remove('$cachedMessagesPrefix$chatId');

    // Also remove the chat from the main list cache
    final jsonList = sharedPreferences.getStringList(cachedChatsList);
    if (jsonList != null) {
      final chats = jsonList
          .map((json) => ChatModel.fromJson(jsonDecode(json)))
          .toList();
      chats.removeWhere((chat) => chat.id == chatId);
      await cacheChats(chats);
    }
  }
}

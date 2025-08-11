import 'package:dartz/dartz.dart';

import '../../../../core/constants/message_type.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/data/datasources/local_data_source.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/realtime_event.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, void>> deleteChat(String chatId) async {
    try {
      final String? token = await authLocalDataSource.getToken();
      if (token == null) {
        return const Left(UnauthorizedFailure('User not authenticated'));
      }
      await remoteDataSource.deleteChat(chatId, token);
      try {
        await localDataSource.clearCacheForChat(chatId);
      } catch (_) {}
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure('Failed to delete chat'));
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> getChatById(String chatId) async {
    final String? token = await authLocalDataSource.getToken();
    if (token == null) {
      return const Left(UnauthorizedFailure('User not authenticated'));
    }
    try {
      final ChatModel chat = await remoteDataSource.getChatById(chatId, token);
      // Cache the fresh chat
      try {
        await localDataSource.cacheChat(chat);
        // Also try to update the cached chats list
        try {
          final existing = await localDataSource.getLastChats();
          final updated = List<ChatModel>.from(existing);
          final idx = updated.indexWhere((c) => c.id == chat.id);
          if (idx >= 0) {
            updated[idx] = chat;
          } else {
            updated.insert(0, chat);
          }
          await localDataSource.cacheChats(updated);
        } catch (_) {}
      } catch (_) {}
      return Right(chat);
    } on ServerException {
      try {
        final cached = await localDataSource.getLastChatById(chatId);
        return Right(cached);
      } on CacheException {
        return const Left(ServerFailure('Failed to get chat by id'));
      }
    }
  }

  @override
  Future<Either<Failure, List<ChatEntity>>> getChats() async {
    final String? token = await authLocalDataSource.getToken();
    if (token == null) {
      return const Left(UnauthorizedFailure('User not authenticated'));
    }
    try {
      final chats = await remoteDataSource.getChats(token);
      // Cache the fresh chats if possible
      try {
        final models = chats.whereType<ChatModel>().toList();
        if (models.isNotEmpty) {
          await localDataSource.cacheChats(models);
        }
      } catch (_) {}
      final chatEntity = chats.map((e) => e.toEntity()).toList();
      return Right(chatEntity);
    } on ServerException {
      try {
        final cached = await localDataSource.getLastChats();
        return Right(cached.cast<ChatEntity>());
      } on CacheException {
        return const Left(ServerFailure('Failed to get chats'));
      }
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String chatId,
  ) async {
    final String? token = await authLocalDataSource.getToken();
    if (token == null) {
      return const Left(UnauthorizedFailure('User not authenticated'));
    }
    try {
      final messages = await remoteDataSource.getMessages(chatId, token);
      // Cache the fresh messages if possible
      try {
        final models = messages.whereType<MessageModel>().toList();
        if (models.isNotEmpty) {
          await localDataSource.cacheMessages(chatId, models);
        }
      } catch (_) {}
      return Right(messages);
    } on ServerException {
      try {
        final cached = await localDataSource.getLastMessages(chatId);
        return Right(cached.cast<MessageEntity>());
      } on CacheException {
        return const Left(ServerFailure('Failed to get messages'));
      }
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> initiateChat(String receiverId) async {
    final String? token = await authLocalDataSource.getToken();
    if (token == null) {
      return const Left(UnauthorizedFailure('User not authenticated'));
    }
    try {
      final ChatModel chat = await remoteDataSource.initiateChat(
        receiverId,
        token,
      );
      // Cache the new chat
      try {
        await localDataSource.cacheChat(chat);
        try {
          final existing = await localDataSource.getLastChats();
          final updated = List<ChatModel>.from(existing);
          final idx = updated.indexWhere((c) => c.id == chat.id);
          if (idx >= 0) {
            updated[idx] = chat;
          } else {
            updated.insert(0, chat);
          }
          await localDataSource.cacheChats(updated);
        } catch (_) {}
      } catch (_) {}
      return Right(chat);
    } on ServerException {
      return const Left(ServerFailure('Failed to initiate chat'));
    }
  }

  @override
  Future<void> connect() async {
    // The repository is responsible for fetching its own token.
    final token = await authLocalDataSource.getToken();
    if (token == null) {
      throw const UnauthorizedFailure('User not authenticated');
    }
    remoteDataSource.connect(token);
  }

  @override
  void disconnect() {
    remoteDataSource.disconnect();
  }

  @override
  Stream<RealtimeEvent> getRealtimeEvents() {
    return remoteDataSource.getRealtimeEvents();
  }

  @override
  void sendMessage({
    required String chatId,
    required String content,
    required MessageType type,
  }) {
    remoteDataSource.sendMessage(chatId: chatId, content: content, type: type);
  }

  @override
  void markChatAsRead(String chatId) {
    remoteDataSource.markChatAsRead(chatId);
  }
}

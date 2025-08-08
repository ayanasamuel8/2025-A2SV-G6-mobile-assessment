import 'package:dartz/dartz.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, void>> deleteChat(String chatId, String token) async {
    try {
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
  Future<Either<Failure, ChatEntity>> getChatById(
    String chatId,
    String token,
  ) async {
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
  Future<Either<Failure, List<ChatEntity>>> getChats(String token) async {
    try {
      final chats = await remoteDataSource.getChats(token);
      // Cache the fresh chats if possible
      try {
        final models = chats.whereType<ChatModel>().toList();
        if (models.isNotEmpty) {
          await localDataSource.cacheChats(models);
        }
      } catch (_) {}
      return Right(chats);
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
    String token,
  ) async {
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
  Future<Either<Failure, ChatEntity>> initiateChat(
    String receiverId,
    String token,
  ) async {
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
}

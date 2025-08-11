import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

class ChatEntity extends Equatable {
  final String id;
  final User user1;
  final User user2;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const ChatEntity({
    required this.id,
    required this.user1,
    required this.user2,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [id, user1, user2, lastMessage, lastMessageTime];
}

import 'package:equatable/equatable.dart';

import '../../../../injection_container.dart' as di;
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ChatEntity extends Equatable {
  final String id;
  final User user1;
  final User user2;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  // Your standard constructor
  const ChatEntity({
    required this.id,
    required this.user1,
    required this.user2,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  // --- THIS IS THE CORRECTED FACTORY CONSTRUCTOR ---
  factory ChatEntity.createPlaceholder({required User receiver}) {
    // 1. Get the current state of the AuthBloc.
    final authState = di.sl<AuthBloc>().state;

    // 2. Safely check if the state is 'Authenticated'.
    if (authState is Authenticated) {
      // If it is, we can safely get the current user and create the entity.
      final currentUser = authState.user;
      return ChatEntity(
        id: '', // Empty ID because it's a placeholder
        user1: currentUser!,
        user2: receiver,
        lastMessage: null,
        lastMessageTime: null,
        unreadCount: 0,
      );
    } else {
      // 3. If the user is not authenticated, this is a critical logic error.
      //    Throw a descriptive exception to make debugging easier.
      //    This is much better than the cryptic 'TypeError' you were getting before.
      throw Exception(
        'User is not authenticated. Cannot create a chat placeholder.',
      );
    }
  }

  // Equatable props for comparison
  @override
  List<Object?> get props => [
    id,
    user1,
    user2,
    lastMessage,
    lastMessageTime,
    unreadCount,
  ];

  // A copyWith method is also very useful for state management
  ChatEntity copyWith({
    String? id,
    User? user1,
    User? user2,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      user1: user1 ?? this.user1,
      user2: user2 ?? this.user2,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

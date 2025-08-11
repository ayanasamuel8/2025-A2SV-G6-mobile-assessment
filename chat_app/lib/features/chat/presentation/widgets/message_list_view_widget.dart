import 'package:flutter/material.dart';
import '../../../../core/constants/avatars.dart';
import '../../domain/entities/message_entity.dart';
import 'chat_bubble_widget.dart';

class MessageListView extends StatelessWidget {
  final List<MessageEntity> messages;
  final String currentUserId;
  final String profileUrl;

  const MessageListView({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.profileUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text('No messages yet. Start the conversation!'),
      );
    }

    final reversedMessages = messages.reversed.toList();
    final myProfileUrl = AppAvatars.avatars[0];

    return ListView.builder(
      reverse: true,
      itemCount: reversedMessages.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        final message = reversedMessages[index];
        final bool isMe = message.sender.id == currentUserId;
        return ChatBubble(
          message: message,
          isMe: isMe,
          profileUrl: isMe ? myProfileUrl : profileUrl,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/message_entity.dart';

class ChatBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final String profileUrl;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.profileUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width for constraining the bubble size
    final screenWidth = MediaQuery.of(context).size.width;

    // The main content of the message bubble
    final bubbleContent = Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: isMe ? primary() : bubbleBack(),
        borderRadius: isMe
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(2), // Flat corner for "tip" effect
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(2), // Flat corner for "tip" effect
              ),
      ),
      child: Row(
        // Use a Row for the content and status icon
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Constrain the text to prevent it from overflowing
          Flexible(
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isMe ? white() : black(),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            _buildStatusIcon(message.status),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(backgroundImage: NetworkImage(profileUrl), radius: 20),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  message.sender.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: black(),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
                child: bubbleContent,
              ),

              Padding(
                padding: const EdgeInsets.only(
                  top: 4.0,
                  left: 12.0,
                  right: 12.0,
                ),
                child: Text(
                  TimeOfDay.fromDateTime(
                    message.timestamp.toLocal(),
                  ).format(context),
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          if (isMe)
            CircleAvatar(backgroundImage: NetworkImage(profileUrl), radius: 20),
        ],
      ),
    );
  }

  // --- HELPER METHODS ---

  Widget _buildStatusIcon(MessageStatus status) {
    IconData iconData;
    Color iconColor;
    switch (status) {
      case MessageStatus.sent:
        iconData = Icons.check;
        iconColor = Colors.white70;
        break;
      case MessageStatus.delivered:
        iconData = Icons.done_all;
        iconColor = Colors.white70;
        break;
      case MessageStatus.read:
        iconData = Icons.done_all;
        iconColor = Colors.greenAccent;
        break;
      default:
        // Return an empty box if status is 'sending' or something else
        return const SizedBox.shrink();
    }
    return Icon(iconData, size: 16, color: iconColor);
  }
}

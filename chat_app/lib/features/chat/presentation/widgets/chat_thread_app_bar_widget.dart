import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class ChatThreadAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatThreadAppBar({
    super.key,
    required this.name,
    this.statusStream,
    this.isOnlineInitial = false,
    required this.profileImageUrl,
  });

  final String name;

  final Stream<bool>? statusStream;

  final bool isOnlineInitial;
  final String profileImageUrl;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: white(),
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: black()),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back to chats',
      ),
      title: StreamBuilder<bool>(
        stream: statusStream,
        initialData: isOnlineInitial,
        builder: (context, snapshot) {
          final isOnline = snapshot.data ?? false;
          return Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  profileImageUrl, // Replace with actual avatar URL
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOnline
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF9CA3AF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isOnline
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.call, color: black()),
          onPressed: () {
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orange,
                content: Text('🚧 Under construction'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
          tooltip: 'Voice call',
        ),
        IconButton(
          icon: Icon(Icons.videocam_outlined, color: black()),
          onPressed: () {
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orange,
                content: Text('🚧 Under construction'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
          tooltip: 'Video call',
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

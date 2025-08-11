import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/avatars.dart';
import '../../../auth/domain/entities/user.dart';

Widget buildSingleChatWidget(User user) {
  return Row(
    children: [
      CircleAvatar(
        backgroundImage: NetworkImage(
          AppAvatars.avatars[Random().nextInt(AppAvatars.avatars.length)],
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ],
  );
}

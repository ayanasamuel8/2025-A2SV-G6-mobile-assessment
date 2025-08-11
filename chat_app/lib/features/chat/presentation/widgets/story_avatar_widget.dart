import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/mock_user_with_story.dart';

Widget storyAvatar(
  UserWithStories u, {
  double radius = 30,
  bool withRing = false,
}) {
  return Container(
    padding: withRing ? const EdgeInsets.all(2.5) : EdgeInsets.zero,
    decoration: withRing
        ? const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.orangeAccent],
            ),
          )
        : null,
    child: CircleAvatar(
      radius: radius,
      backgroundColor: primary(),
      child: Text(
        u.name.substring(0, 1),
        style: TextStyle(
          color: primary(),
          fontWeight: FontWeight.bold,
          fontSize: radius,
        ),
      ),
    ),
  );
}

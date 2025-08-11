import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/mock_user_with_story.dart';
import 'story_avatar_widget.dart';

Widget buildMiniStackedStories(double t) {
  final List<UserWithStories> mockUserWithStories = kMockUsersWithStories;
  final firstThree = mockUserWithStories.take(3).toList(growable: false);

  final double radius = lerpDouble(16, 30, t)!;
  final double spacing = lerpDouble(22, 84, t)!;
  final double width = (firstThree.length - 1) * spacing + radius * 2;
  final double height = radius * 2;

  // Vertical travel to the stories row area
  final double dy = lerpDouble(0, 54, t)!;

  return Transform.translate(
    offset: Offset(0, dy),
    child: SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < firstThree.length; i++)
            Positioned(
              left: i * spacing,
              child: storyAvatar(firstThree[i], radius: radius, withRing: true),
            ),
        ],
      ),
    ),
  );
}

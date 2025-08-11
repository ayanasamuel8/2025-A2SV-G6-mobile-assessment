import 'package:flutter/material.dart';

import '../../../../core/constants/mock_user_with_story.dart';
import 'open_stories_widget.dart';
import 'story_avatar_widget.dart';

Widget buildStories() {
  final List<UserWithStories> mockUserWithStories = kMockUsersWithStories;
  final storyUsers = mockUserWithStories.toList();
  return SizedBox(
    height: 92,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: storyUsers.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, i) {
        final u = storyUsers[i];
        return GestureDetector(
          onTap: () => openStories(u, context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              storyAvatar(u, radius: 30, withRing: true),
              const SizedBox(height: 6),
              SizedBox(
                width: 70,
                child: Text(
                  u.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

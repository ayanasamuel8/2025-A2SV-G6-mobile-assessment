import 'package:flutter/material.dart';

import '../../../../core/constants/mock_user_with_story.dart';
import 'story_viewer_widget.dart';

void openStories(UserWithStories user, BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.85),
      pageBuilder: (_, _, _) => StoryViewer(user: user),
    ),
  );
}

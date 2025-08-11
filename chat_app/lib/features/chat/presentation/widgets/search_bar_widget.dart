import 'package:flutter/material.dart';
import 'mini_stacked_stories_widget.dart'; // Make sure this import is correct

/// Builds a static search bar that acts as a navigation button.
/// It displays an icon on the left and leaves space for the mini-stories,
/// matching the original "closed" state of the animated search bar.
Widget buildSearchBar(
  BuildContext context, {
  required VoidCallback onTap,
  required bool showLargeStories,
  required double revealT,
  required VoidCallback onLogout,
}) {
  const double iconContainerSize = 44.0;
  const double gap = 10.0;

  return Row(
    children: [
      GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(
              width: iconContainerSize,
              height: iconContainerSize,
              child: Icon(Icons.search, color: Colors.white),
            ),
          ),
        ),
      ),
      if (!showLargeStories)
        Padding(
          padding: const EdgeInsets.only(left: gap),
          child: buildMiniStackedStories(revealT),
        ),
      const Spacer(), // Pushes the logout button to the end
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        tooltip: 'Logout',
        onPressed: onLogout,
      ),
    ],
  );
}

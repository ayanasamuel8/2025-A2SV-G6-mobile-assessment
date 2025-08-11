import 'package:flutter/material.dart';

import 'mini_stacked_stories_widget.dart';

Widget buildSearchBar(
  bool searchExpanded,
  TextEditingController searchCtrl,
  bool showLargeStories,
  double revealT,
  VoidCallback setState,
) {
  return LayoutBuilder(
    builder: (context, c) {
      final double iconSize = 44;
      final double gap = 10;
      final double fieldMaxWidth = c.maxWidth - iconSize - gap;

      return SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: searchExpanded ? fieldMaxWidth : 0,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: searchExpanded
                  ? TextField(
                      controller: searchCtrl,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) {
                        //TODO: hook to filter chats if needed
                      },
                    )
                  : null,
            ),

            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: searchExpanded
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  setState();
                },
                child: Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),

            // Mini stories morphing towards the large row while dragging down
            // Only visible until the large row is fully revealed
            if (!searchExpanded && !showLargeStories)
              Positioned(
                left: iconSize + gap,
                child: buildMiniStackedStories(revealT),
              ),
          ],
        ),
      );
    },
  );
}

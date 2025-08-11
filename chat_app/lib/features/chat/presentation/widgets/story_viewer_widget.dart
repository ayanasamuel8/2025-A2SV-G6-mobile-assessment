import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/mock_user_with_story.dart';

class StoryViewer extends StatefulWidget {
  final UserWithStories user;
  const StoryViewer({super.key, required this.user});

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  int _index = 0;
  final int _max = 3;

  void _next() {
    if (_index < _max - 1) {
      setState(() => _index++);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _next,
      onVerticalDragEnd: (_) => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.9),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 120,
                  backgroundColor: primary(),
                  child: Text(
                    '${widget.user.name}\nStory ${_index + 1}/$_max',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primary(),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: List.generate(
                    _max,
                    (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == _max - 1 ? 0 : 6),
                        height: 3,
                        decoration: BoxDecoration(
                          color: i <= _index ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 12,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: primary(),
                      child: Text(
                        widget.user.name.substring(0, 1),
                        style: TextStyle(
                          color: primary(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

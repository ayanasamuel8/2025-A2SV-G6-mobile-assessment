import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class MessageInputArea extends StatefulWidget {
  final bool isLoading;
  final TextEditingController controller;
  final VoidCallback onSendPressed;

  const MessageInputArea({
    super.key,
    required this.isLoading,
    required this.controller,
    required this.onSendPressed,
  });

  @override
  State<MessageInputArea> createState() => _MessageInputAreaState();
}

class _MessageInputAreaState extends State<MessageInputArea> {
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty != _showSendButton) {
      setState(() {
        _showSendButton = text.isNotEmpty;
      });
    }
  }

  void _showUnderConstructionSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.orange,
        content: Text('🚧 Feature is under construction'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file, color: black()),
              onPressed: _showUnderConstructionSnackBar,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    hintStyle: TextStyle(
                      color: darkGrey(),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) =>
                      widget.isLoading ? null : widget.onSendPressed(),
                ),
              ),
            ),
            // The loading indicator takes highest priority
            if (widget.isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
              )
            else
              // AnimatedSwitcher for a smooth transition between button sets
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: _showSendButton
                    ? IconButton(
                        // Show SEND button
                        key: const ValueKey('send_button'),
                        icon: Icon(Icons.send, color: primary()),
                        onPressed: widget.onSendPressed,
                      )
                    : Row(
                        // Show ACTION buttons
                        key: const ValueKey('action_buttons'),
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt_outlined,
                              color: black(),
                            ),
                            onPressed: _showUnderConstructionSnackBar,
                          ),
                          IconButton(
                            icon: Icon(Icons.mic, color: black()),
                            onPressed: _showUnderConstructionSnackBar,
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

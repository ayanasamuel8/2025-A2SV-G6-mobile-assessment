import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/avatars.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/message_type.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../bloc/chat_thread_bloc.dart';
import '../widgets/chat_thread_app_bar_widget.dart';
import '../widgets/message_input_area_widget.dart';
import '../widgets/message_list_view_widget.dart';

class ChatThreadPage extends StatefulWidget {
  const ChatThreadPage({
    super.key,
    required this.chat,
    required this.currentUserId,
  });
  final ChatEntity chat;
  final String currentUserId;

  @override
  State<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<ChatThreadPage> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    di.sl<ChatRepository>().markChatAsRead(widget.chat.id);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    final currentState = context.read<ChatThreadBloc>().state;
    // Prevent sending while another message is being processed
    if (text.isNotEmpty &&
        currentState is ChatThreadLoaded &&
        !currentState.isSending) {
      context.read<ChatThreadBloc>().add(
        SendMessageEvent(content: text, type: MessageType.text),
      );
      _textController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely get the current authenticated user
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) {
      // Robustly handle cases where user is not authenticated yet
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final currentUserId = authState.user!.id;
    final profileUrl =
        AppAvatars.avatars[Random().nextInt(AppAvatars.avatars.length - 1)];

    return BlocListener<ChatThreadBloc, ChatThreadState>(
      listener: (context, state) {
        if (state is ChatThreadActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<ChatThreadBloc, ChatThreadState>(
        builder: (context, state) {
          if (state is ChatThreadLoaded) {
            return Scaffold(
              backgroundColor: white(),
              appBar: ChatThreadAppBar(
                name: currentUserId == widget.chat.user1.id
                    ? widget.chat.user2.name
                    : widget.chat.user1.name,
                profileImageUrl: profileUrl,
              ),
              body: Column(
                children: [
                  Expanded(
                    child: MessageListView(
                      messages: state.messages,
                      currentUserId: currentUserId,
                      profileUrl: profileUrl,
                    ),
                  ),
                  MessageInputArea(
                    controller: _textController,
                    isLoading: state.isSending,
                    onSendPressed: _sendMessage,
                  ),
                ],
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: Colors.blueGrey.shade50,
              appBar: ChatThreadAppBar(
                name: 'Loading...',
                profileImageUrl: AppAvatars.avatars[0],
              ),
              body: Center(
                child: state is ChatThreadError
                    ? Text('An error occurred: ${state.message}')
                    : const CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

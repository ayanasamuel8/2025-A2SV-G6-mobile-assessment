import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart'; // Import your colors
import '../../../../injection_container.dart' as di;
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/chat_entity.dart';
import '../bloc/chat_thread_bloc.dart';
import '../bloc/user_search_bloc.dart';
import 'chat_thread_page.dart';

class NewChatPage extends StatelessWidget {
  const NewChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the UserSearchBloc to the widget tree of this page.
    return BlocProvider(
      create: (context) => di.sl<UserSearchBloc>(),
      child: const _NewChatView(),
    );
  }
}

class _NewChatView extends StatelessWidget {
  const _NewChatView();

  // Navigation logic now only needs the receiver's User entity.
  void _initiateChatAndNavigate(BuildContext context, User receiver) {
    // Create the temporary placeholder entity for the UI to build instantly.
    final placeholderChat = ChatEntity.createPlaceholder(receiver: receiver);

    // Replace the current page with the chat thread.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) =>
              di.sl<ChatThreadBloc>()
                ..add(InitiateChatEvent(receiverId: receiver.id)),
          // The ChatThreadPage is cleaner now, only needing the chat entity.
          child: ChatThreadPage(chat: placeholderChat),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Apply your app's theme colors
      backgroundColor: white(),
      appBar: AppBar(
        // The AppBar has a custom background color and a search bar as its title.
        backgroundColor: secondary(),
        titleSpacing: 0, // Remove default spacing
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Make back arrow white
        title: _buildSearchAppBar(context),
      ),
      body: _buildSearchResultsList(),
    );
  }

  /// Builds a custom AppBar title containing the search TextField.
  Widget _buildSearchAppBar(BuildContext context) {
    return TextField(
      autofocus: true,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        // A borderless input field for a clean look
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        // The hint text to guide the user
        hintText: 'Search by name...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
      onChanged: (query) {
        // Dispatch the search event to the BLoC on every keystroke.
        context.read<UserSearchBloc>().add(SearchQueryChanged(query));
      },
    );
  }

  /// Builds the body of the scaffold, which displays the search results.
  Widget _buildSearchResultsList() {
    return BlocBuilder<UserSearchBloc, UserSearchState>(
      builder: (context, state) {
        if (state is UserSearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserSearchSuccess) {
          if (state.users.isEmpty) {
            return const Center(
              child: Text(
                'No users found.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          // Display the search results in a clean ListView
          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.name.substring(0, 1).toUpperCase()),
                ),
                title: Text(user.name),
                subtitle: Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () => _initiateChatAndNavigate(context, user),
              );
            },
          );
        }
        if (state is UserSearchFailure) {
          return Center(child: Text(state.message));
        }
        // Initial state message to guide the user
        return const Center(
          child: Text(
            'Find people to start a conversation.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}

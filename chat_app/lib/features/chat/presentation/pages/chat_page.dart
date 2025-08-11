import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/avatars.dart';
import '../../../../core/constants/colors.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/chat_list_bloc.dart';
import '../bloc/chat_thread_bloc.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/story_widget.dart';
import 'chat_thread_page.dart';
import 'new_chat_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();

  static const double _minExtent = 0.70;
  static const double _initialExtent = 0.85;
  static const double _maxExtent = 0.87;
  double _sheetExtent = _initialExtent;

  double get _revealT =>
      ((_initialExtent - _sheetExtent) / (_initialExtent - _minExtent)).clamp(
        0.0,
        1.0,
      );

  bool get _showLargeStories => _revealT >= 0.999;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<ChatListBloc>().add(GetChatsListEvent());
    print('ChatPage initialized');
  }

  @override
  Widget build(BuildContext context) {
    // Upper area height to reveal when sheet is dragged down
    const double topAreaHeight = 210;
    final authState = context.watch<AuthBloc>().state;
    final currentUser = authState is Authenticated
        ? authState.user
        : null; // Get current user from AuthBloc state

    return BlocConsumer<ChatListBloc, ChatListState>(
      listener: (context, state) {
        if (state is ChatListError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is ChatListActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: secondary(),
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: SizedBox(
                  height: topAreaHeight,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: buildSearchBar(
                          onLogout: () {
                            _showLogoutConfirmationDialog(context);
                          },
                          context,
                          showLargeStories: _showLargeStories,
                          revealT: _revealT,
                          onTap: () {
                            setState(() {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NewChatPage(),
                                ),
                              );
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _showLargeStories
                                ? buildStories()
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              NotificationListener<DraggableScrollableNotification>(
                onNotification: (n) {
                  setState(() => _sheetExtent = n.extent);
                  return true;
                },
                child: _buildBody(context, state, currentUser),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChatListState state,
    User? currentUser,
  ) {
    if (state is ChatListLoading || state is ChatListInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ChatListLoaded) {
      return _buildDraggableChats(context, state.chats, currentUser);
    }
    if (state is ChatListError) {
      return Center(child: Text('Failed to load chats: ${state.message}'));
    }
    return const SizedBox.shrink();
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    // We use the root context from the Builder to ensure it can find the BLoC.
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // First, close the dialog
                Navigator.of(dialogContext).pop();
                // Then, dispatch the logout event.
                // context.read is used for one-time actions in callbacks.
                authBloc.add(const LogoutEvent());
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDraggableChats(BuildContext context, chats, currentUser) {
    return DraggableScrollableSheet(
      initialChildSize: _initialExtent,
      minChildSize: _minExtent,
      maxChildSize: _maxExtent,
      snap: true,
      snapSizes: const [_minExtent, _initialExtent, _maxExtent],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: white(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Grab handle to show it's slideable
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: chats.length,
                  padding: const EdgeInsets.only(top: 4, bottom: 20),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final chat = chats[i];
                    final user = chat.user1.id == currentUser?.id
                        ? chat.user2
                        : chat.user1;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(AppAvatars.avatars[1]),
                        child: Stack(
                          children: [
                            if (Random().nextBool())
                              Positioned(
                                right: 10,
                                bottom: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      minLeadingWidth: 0,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        chat.lastMessage ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            chat.lastMessageTime != null
                                ? TimeOfDay.fromDateTime(
                                    chat.lastMessageTime!,
                                  ).format(context)
                                : '',
                          ),
                          if (chat.unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: primary(),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${chat.unreadCount < 10 ? chat.unreadCount : '9+'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (context) => di.sl<ChatThreadBloc>()
                                ..add(FetchThreadDataEvent(chatId: chat.id)),
                              child: ChatThreadPage(chat: chat),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

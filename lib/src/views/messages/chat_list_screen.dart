import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/domain/models/Chat.dart';
import '../../../core/domain/models/User.dart' as models;
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../blocs/message/message_bloc.dart';
import '../../blocs/message/message_event.dart';
import '../../blocs/message/message_state.dart';
import '../../blocs/user/user_repository.dart';
import '../../widget_build/chat_item.dart';
import '../layout/bottom_nav_bar.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  final models.User currentUser;

  const ChatListScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChats(widget.currentUser.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              widget.currentUser.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.black, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                // TODO: Xử lý filter chat theo tên hoặc tin nhắn
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.grey[600], size: 20),
                      Text(
                        'Ghi chú...',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.flag, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tin nhắn',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Tin nhắn đang chờ',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                print('ChatListScreen: Current ChatState = $state');
                if (state is ChatLoading) {
                  print('ChatListScreen: loading...');
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatLoaded) {
                  if (state.chats.isEmpty) {
                    print('ChatListScreen: no chats');
                    return const Center(
                      child: Text('Bạn chưa có cuộc trò chuyện nào'),
                    );
                  }
                  print(
                    'ChatListScreen: loaded with ${state.chats.length} chats',
                  );
                  return ListView.builder(
                    itemCount: state.chats.length,
                    itemBuilder: (context, index) {
                      final chat = state.chats[index];
                      print(
                        'ChatListScreen: building chat item for chatId: ${chat.chatId}',
                      );
                      return ChatItem(
                        chat: chat,
                        onTap: () async {
                          final otherUser = await getOtherUser(chat.userIds); // Await the Future
                          if (otherUser != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  chatId: chat.chatId,
                                  otherUser: otherUser, // Now it's a models.User, not a Future
                                  currentUserId: widget.currentUser.id,
                                ),
                              ),
                            );
                          } else {
                            // Handle the case where otherUser is null (optional)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Không thể tải thông tin người dùng')),
                            );
                          }
                        },
                      );
                    },
                  );
                } else if (state is ChatError) {
                  print('ChatListScreen: error ${state.error}');
                  return Center(child: Text('Lỗi: ${state.error}'));
                }
                print('ChatListScreen: default no data');
                return const Center(child: Text('Không có dữ liệu'));
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        user: widget.currentUser,
        isCurrentUser: true,
      ),
    );
  }
}

String _formatTime(Timestamp timestamp) {
  final now = Timestamp.now().toDate();
  final time = timestamp.toDate();
  final diff = now.difference(time);

  if (diff.inMinutes < 1) return 'vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

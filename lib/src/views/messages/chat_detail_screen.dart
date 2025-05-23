import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/domain/models/User.dart' as models;
import '../../../core/domain/models/Message.dart' as models;
import '../../blocs/message/message_bloc.dart';
import '../../blocs/message/message_event.dart';
import '../../blocs/message/message_state.dart';
import '../../widget_build/message_item.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final models.User otherUser;
  final String currentUserId;

  const ChatDetailScreen({
    Key? key,
    required this.chatId,
    required this.otherUser,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<MessageBloc>().add(LoadMessages(widget.chatId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final message = models.Message(
      id: '', // Firestore sẽ tự tạo ID
      chatId: widget.chatId,
      senderId: widget.currentUserId,
      receiverId: widget.otherUser.id,
      content: content,
      timestamp: Timestamp.now(),
    );

    context.read<MessageBloc>().add(SendMessageEvent(message));
    _messageController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUser.avatarUrl.isNotEmpty
                  ? NetworkImage(widget.otherUser.avatarUrl)
                  : null,
              child: widget.otherUser.avatarUrl.isEmpty
                  ? Text(
                widget.otherUser.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(widget.otherUser.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<MessageBloc, MessageState>(
              listener: (context, state) {
                if (state is MessageLoadedState) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is MessageLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MessageLoadedState) {
                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return const Center(child: Text('Chưa có tin nhắn nào'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == widget.currentUserId;
                      return MessageItem(
                        message: msg,
                        isMe: isMe,
                      );
                    },
                  );
                } else if (state is MessageErrorState) {
                  return Center(child: Text('Lỗi: ${state.error}'));
                }
                return const Center(child: Text('Không có dữ liệu'));
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
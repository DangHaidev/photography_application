import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/domain/models/Chat.dart';
import '../../core/domain/models/User.dart' as models;
import '../../core/domain/models/Message.dart' as models;
import '../blocs/message/message_repository.dart';
import '../blocs/user/user_repository.dart';

class ChatItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback? onTap;

  const ChatItem({
    Key? key,
    required this.chat,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<models.User?>(
      future: getOtherUser(chat.userIds),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            title: const Text('Đang tải...'),
          );
        }

        if (userSnapshot.hasError || !userSnapshot.hasData || userSnapshot.data == null) {
          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey,
              child: const Text('?'),
            ),
            title: const Text('Người dùng không xác định'),
          );
        }

        final otherUser = userSnapshot.data!;

        return FutureBuilder<models.Message?>(
          future: fetchLatestMessage(chat.chatId),
          builder: (context, messageSnapshot) {
            String subtitle = 'Chưa có tin nhắn';
            String timestamp = '';

            if (messageSnapshot.connectionState == ConnectionState.waiting) {
              subtitle = 'Đang tải...';
            } else if (messageSnapshot.hasData && messageSnapshot.data != null) {
              final messageData = messageSnapshot.data!;
              subtitle = messageData.content;
              timestamp = DateFormat('HH:mm').format(messageData.timestamp.toDate());
            }

            return ListTile(
              onTap: onTap,
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: otherUser.avatarUrl.isNotEmpty
                    ? NetworkImage(otherUser.avatarUrl)
                    : null,
                child: otherUser.avatarUrl.isEmpty
                    ? Text(
                  otherUser.name.isNotEmpty ? otherUser.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
              title: Text(
                  otherUser.name,
                style: TextStyle(
                  color: Colors.black
                ),
              ),
              subtitle: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Text(
                timestamp,
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            );
          },
        );
      },
    );
  }
}
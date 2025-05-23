import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/domain/models/Message.dart' as models;

class MessageItem extends StatelessWidget {
  final models.Message message;
  final bool isMe;

  const MessageItem({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                  fontSize: 16,
                color: Colors.black
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp.toDate()),
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
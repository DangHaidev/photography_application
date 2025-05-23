import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final Timestamp timestamp;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromDocument(Map<String, dynamic> doc, String docId) {
    return Message(
      id: docId,
      chatId: doc['chatId'] ?? '',
      senderId: doc['senderId'] ?? '',
      receiverId: doc['receiverId'] ?? '',
      content: doc['content'] ?? '',
      timestamp: doc['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
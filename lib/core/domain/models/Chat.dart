import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final List<String> userIds;
  final String? lastMessageId;

  Chat({
    required this.chatId,
    required this.userIds,
    this.lastMessageId,
  });

  factory Chat.fromMap(Map<String, dynamic> map, String docId) {
    return Chat(
      chatId: docId,
      userIds: List<String>.from(map['userIds'] ?? []),
      lastMessageId: map['lastMessageId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds,
      'lastMessageId': lastMessageId,
    };
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id;
  final String type; // "like" or "comment"
  final String fromUserId;
  final String postId;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.type,
    required this.fromUserId,
    required this.postId,
    required this.createdAt,
  });

  factory Notification.fromMap(String id, Map<String, dynamic> data) {
    return Notification(
      id: id,
      type: data['type'],
      fromUserId: data['fromUserId'],
      postId: data['postId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'fromUserId': fromUserId,
      'postId': postId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

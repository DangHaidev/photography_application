import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String content;
  final Timestamp createdAt;
  final int likeCount;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    Timestamp createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = json['createdAt'] as Timestamp;
    } else if (json['createdAt'] is String) {
      try {
        final dateTime = DateTime.parse(json['createdAt'] as String);
        createdAt = Timestamp.fromDate(dateTime);
      } catch (e) {
        print('Error parsing createdAt string: $e');
        createdAt = Timestamp.now();
      }
    } else {
      createdAt = Timestamp.now();
    }

    return Comment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      createdAt: createdAt,
      likeCount: json['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
      'likeCount': likeCount,
    };
  }

  Comment copyWith({
    String? id,
    String? userId,
    String? content,
    Timestamp? createdAt,
    int? likeCount,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}
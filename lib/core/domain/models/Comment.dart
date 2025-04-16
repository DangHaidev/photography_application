import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String content;
  final Timestamp createdAt;
  final int likeCount;
  final bool isLiked;
  final List<Comment>? replies;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'],
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      replies:
          json['replies'] != null
              ? (json['replies'] as List)
                  .map((reply) => Comment.fromJson(reply))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'replies': replies?.map((reply) => reply.toJson()).toList(),
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

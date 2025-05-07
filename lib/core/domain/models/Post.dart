import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String imageUrl;
  final String caption;
  final Timestamp createdAt;
  final int likeCount;
  final int commentCount;

  Post({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount
  });

  factory Post.fromMap(String id, Map<String, dynamic> data) {
    return Post(
      id: id,
      userId: data['userId'] ?? 'Unknown',
      imageUrl:
          data['imageUrl'] ??
          'https://hoanghamobile.com/tin-tuc/wp-content/uploads/2023/07/anh-dep-thien-nhien-thump.jpg',
      caption: data['caption'] ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': createdAt,
      'likeCount': likeCount,
      'commentCount': commentCount,
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? caption,
    Timestamp? createdAt,
    int? likeCount,
    int? commentCount,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount
    );
  }
}

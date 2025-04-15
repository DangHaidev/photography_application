import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String imageUrl;
  final String caption;
  final Timestamp createdAt;
  final int likeCount;

  Post({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    required this.likeCount,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': createdAt,
      'likeCount': likeCount,
    };
  }
}

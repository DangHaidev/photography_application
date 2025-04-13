import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photography_application/core/domain/models/Comment.dart'; // Đường dẫn model Comment của bạn

class CommentList extends StatelessWidget {
  final String postId;

  const CommentList({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: true) // newest first
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Lỗi khi lấy dữ liệu.');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final comments = docs.map((doc) => Comment.fromDocument(doc)).toList();

        if (comments.isEmpty) {
          return const Text('Chưa có bình luận nào.');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              title: Text(comment.userId, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(comment.content),
              trailing: Text(
                '${comment.createdAt.hour}:${comment.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photography_application/core/domain/models/Post.dart';

Future<void> submitPost({
  required String caption,
  required String imageUrl,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User not logged in");

  final postRef = FirebaseFirestore.instance.collection('posts').doc();
  final post = Post(
    caption: caption,
    imageUrl: imageUrl,
    userId: user.uid,
    createdAt: Timestamp.now(),
    likeCount: 0, 
    id: postRef.id, commentCount: 0
  );

  await postRef.set(post.toMap());
}

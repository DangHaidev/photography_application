import 'package:cloud_firestore/cloud_firestore.dart';

class Follow {
  final String followerId;
  final String followingId;

  // Constructor
  Follow({required this.followerId, required this.followingId});

  // Factory method to create a Follow object from Firestore document
  factory Follow.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Follow(
      followerId: data['followerId'],
      followingId: data['followingId'],
    );
  }

  // Method to convert Follow object to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {'followerId': followerId, 'followingId': followingId};
  }
}

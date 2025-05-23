import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String bio;
  final int totalFollowers;
  final int totalPosts;
  final int totalDownloadPosts;
  final Timestamp createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    required this.totalFollowers,
    required this.totalPosts,
    required this.totalDownloadPosts,
    required this.createdAt
  });

  factory User.fromMap(String id, Map<String, dynamic> data) {
      return User(
        id: id,
        name: data['name'] ?? 'Unknown User',
        email: data['email'] ?? '',
        avatarUrl: data['avatarUrl'] ?? '',
        bio: data['bio'] ?? '',
        totalFollowers: data['totalFollowers'] ?? 0,
        totalPosts: data['totalPosts'] ?? 0,
        totalDownloadPosts: data['totalDownloadPosts'] ?? 0,
        createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      );
    }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'avatarUrl': avatarUrl, 'bio': bio, 'totalFollowers': totalFollowers, 'totalPosts': totalPosts, 'totalDownloadPosts': totalDownloadPosts, 'createdAt': createdAt};
  }

  factory User.fromFirebaseUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      return User(
        id: '',
        name: 'Guest',
        email: '',
        avatarUrl: 'https://via.placeholder.com/150',
        bio: '',
        totalFollowers: 0,
        totalPosts: 0,
        totalDownloadPosts: 0,
        createdAt: Timestamp.now(),
      );
    }
    return User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Unknown User',
      email: firebaseUser.email ?? '',
      avatarUrl: firebaseUser.photoURL ?? 'https://via.placeholder.com/150',
      bio: '', // Default; fetch from Firestore later
      totalFollowers: 0, // Default; fetch from Firestore later
      totalPosts: 0, // Default; fetch from Firestore later
      totalDownloadPosts: 0, // Default; fetch from Firestore later
      createdAt: Timestamp.now(), // Default; fetch from Firestore later
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    int? totalFollowers,
    int? totalPosts,
    int? totalDownloadPosts,
    Timestamp? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      totalPosts: totalPosts ?? this.totalPosts,
      totalDownloadPosts: totalDownloadPosts ?? this.totalDownloadPosts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      avatarUrl: data['avatarUrl'] ?? 'https://picsum.photos/150',
      name: data['name'] ?? 'Unknown User',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      totalFollowers: data['totalFollowers'] ?? 0,
      totalPosts: data['totalPosts'] ?? 0,
      totalDownloadPosts: data['totalDownloadPosts'] ?? 0,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
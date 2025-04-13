import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photography_application/core/blocs/base_event.dart';
import 'package:photography_application/core/domain/models/Post.dart';

class HomescreenBloc extends BaseEvent with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> fetchPosts() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('posts').get();
      debugPrint("Fetched ${snapshot.docs.length} posts");
      _posts =
          snapshot.docs.map((doc) {
            debugPrint("Document ${doc.id}: ${doc.data()}");
            return Post.fromMap(doc.id, doc.data());
          }).toList();
      debugPrint("Parsed ${_posts.length} posts");
    } catch (e) {
      _error = 'Lỗi tải dữ liệu: $e';
      debugPrint("Error fetching posts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Post> get trendingPosts {
    final filtered =
        _posts.where((post) => post.likeCount > 0).toList(); // Lower threshold
    debugPrint("Trending posts: ${filtered.length}");
    return filtered;
  }

  List<Post> get followingPosts {
    final filtered = _posts; // Show all for now
    debugPrint("Following posts: ${filtered.length}");
    return filtered;
  }

  bool _isFollowing(String userId) {
    return true; // Mock: Include all posts for testing
  }

  Future<void> likePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likeCount': FieldValue.increment(1),
      });
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _posts[postIndex] = Post(
          id: _posts[postIndex].id,
          userId: _posts[postIndex].userId,
          imageUrl: _posts[postIndex].imageUrl,
          caption: _posts[postIndex].caption,
          createdAt: _posts[postIndex].createdAt,
          likeCount: _posts[postIndex].likeCount + 1,
          commentCount: _posts[postIndex].commentCount,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error liking post: $e");
    }
  }

  HomescreenBloc() : super() {
    fetchPosts();
  }
}

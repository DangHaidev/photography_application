import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photography_application/core/blocs/base_event.dart';
import 'package:photography_application/core/domain/models/Post.dart';
import 'package:photography_application/core/domain/models/Comment.dart';

class HomescreenBloc extends BaseEvent with ChangeNotifier {
  List<Post> _posts = [];
  List<String> _likedPosts = [];
  Map<String, List<Comment>> _comments = {};
  Map<String, int> _commentCounts = {};
  Set<String> _expandedPosts = {};
  List<String> _likedComments = [];

  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;

  List<String> get likedPosts => _likedPosts;

  Map<String, List<Comment>> get comments => _comments;

  Map<String, int> get commentCounts => _commentCounts;

  Set<String> get expandedPosts => _expandedPosts;

  List<String> get likedComments => _likedComments;

  bool get isLoading => _isLoading;

  String? get error => _error;

  final commentController = TextEditingController();

  void dispose() {
    commentController.dispose();
  }

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

      for (var post in _posts) {
        await fetchCommentCount(post.id);
      }
    } catch (e) {
      _error = 'Lỗi tải dữ liệu: $e';
      debugPrint("Error fetching posts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCommentCount(String postId) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .get();
      _commentCounts[postId] = snapshot.docs.length;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching comment count for post $postId: $e");
      _commentCounts[postId] = 0;
    }
  }

  List<Post> get trendingPosts {
    final filtered = _posts.where((post) => post.likeCount > 0).toList();
    debugPrint("Trending posts: ${filtered.length}");
    return filtered;
  }

  List<Post> get followingPosts {
    final filtered = _posts;
    debugPrint("Following posts: ${filtered.length}");
    return filtered;
  }

  bool _isFollowing(String userId) {
    return true;
  }

  Future<void> likePost(String postId) async {
    try {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return;

      if (_likedPosts.contains(postId)) {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update(
          {'likeCount': FieldValue.increment(-1)},
        );
        _likedPosts.remove(postId);
        _posts[postIndex] = Post(
          id: _posts[postIndex].id,
          userId: _posts[postIndex].userId,
          imageUrl: _posts[postIndex].imageUrl,
          caption: _posts[postIndex].caption,
          createdAt: _posts[postIndex].createdAt,
          likeCount: _posts[postIndex].likeCount - 1,
        );
      } else {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update(
          {'likeCount': FieldValue.increment(1)},
        );
        _likedPosts.add(postId);
        _posts[postIndex] = Post(
          id: _posts[postIndex].id,
          userId: _posts[postIndex].userId,
          imageUrl: _posts[postIndex].imageUrl,
          caption: _posts[postIndex].caption,
          createdAt: _posts[postIndex].createdAt,
          likeCount: _posts[postIndex].likeCount + 1,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error toggling like for post: $e");
    }
  }

  void toggleComments(String postId) {
    // Không cần toggleComments nữa vì đã sử dụng bottom sheet
  }

  Future<void> loadComments(String postId) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .orderBy('createdAt', descending: true)
              .get();
      _comments[postId] =
          snapshot.docs.map((doc) {
            return Comment.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();
      _commentCounts[postId] = _comments[postId]!.length;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading comments: $e");
    }
  }

  Future<void> addComment(String postId, String content, String userId) async {
    try {
      final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        content: content,
        createdAt: Timestamp.now(),
        likeCount: 0,
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(newComment.id)
          .set(newComment.toJson());

      _comments[postId] = [newComment, ...(_comments[postId] ?? [])];
      _commentCounts[postId] = (_commentCounts[postId] ?? 0) + 1;
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding comment: $e");
    }
  }

  Future<void> likeComment(String postId, String commentId) async {
    try {
      final commentIndex =
          _comments[postId]?.indexWhere((c) => c.id == commentId) ?? -1;
      if (commentIndex == -1) return;

      final comment = _comments[postId]![commentIndex];
      final commentRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      if (_likedComments.contains(commentId)) {
        await commentRef.update({'likeCount': FieldValue.increment(-1)});
        _likedComments.remove(commentId);
        _comments[postId]![commentIndex] = Comment(
          id: comment.id,
          userId: comment.userId,
          content: comment.content,
          createdAt: comment.createdAt,
          likeCount: comment.likeCount - 1,
          isLiked: false,
        );
      } else {
        await commentRef.update({'likeCount': FieldValue.increment(1)});
        _likedComments.add(commentId);
        _comments[postId]![commentIndex] = Comment(
          id: comment.id,
          userId: comment.userId,
          content: comment.content,
          createdAt: comment.createdAt,
          likeCount: comment.likeCount + 1,
          isLiked: true,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error toggling like for comment: $e");
    }
  }

  HomescreenBloc() : super() {
    fetchPosts();
  }
}

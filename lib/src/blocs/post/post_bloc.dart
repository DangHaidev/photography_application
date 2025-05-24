import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/design_systems/design_system_export.dart';
import '../../../core/domain/models/Post.dart';
import '../../../core/domain/models/User.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> _posts = [];
  Set<String> _likedPosts = {};
  Map<String, int> _commentCounts = {};
  List<Post> _userPosts = [];

  PostBloc() : super(PostInitial()) {
    on<FetchPostsEvent>((event, emit) async {
      emit(PostLoading());
      try {
        Query<Map<String, dynamic>> query = _firestore
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .limit(20);

        if (event.startAfter != null) {
          query = query.startAfter([event.startAfter!['createdAt']]);
        }

        final snapshot = await query.get();

        _posts = snapshot.docs
            .map((doc) => Post.fromMap(doc.id, doc.data()))
            .toList();

        _commentCounts = {};
        for (var post in _posts) {
          // Đếm số bình luận từ bộ sưu tập con comments
          final commentCount = await getCommentCount(post.id);
          // Cập nhật commentCount trong Firestore
          await _firestore.collection('posts').doc(post.id).update({
            'commentCount': commentCount,
          });
          _commentCounts[post.id] = commentCount;
          debugPrint('Post ${post.id}: commentCount = ${_commentCounts[post.id]}');
        }

        emit(
          PostLoaded(
            posts: _posts,
            likedPosts: _likedPosts,
            commentCounts: _commentCounts,
            userPosts: _userPosts,
          ),
        );
      } catch (e) {
        emit(PostError("Không thể tải bài đăng: $e"));
      }
    });

    on<FetchUserPostsEvent>((event, emit) async {
      emit(PostLoading());
      try {
        print("Loading posts for user: ${event.userId}");
        final postsSnapshot = await _firestore
            .collection('posts')
            .where('userId', isEqualTo: event.userId)
            .get();

        print("Posts query completed. Found ${postsSnapshot.docs.length} posts");

        if (postsSnapshot.docs.isNotEmpty) {
          print("First post fields: ${postsSnapshot.docs.first.data().keys.join(', ')}");
          print("First post imageUrls: ${postsSnapshot.docs.first.data()['imageUrls']}");
        }

        _userPosts = [];
        for (var doc in postsSnapshot.docs) {
          try {
            _userPosts.add(Post.fromMap(doc.id, doc.data()));
            print("Added post with ID: ${doc.id}, imageUrls: ${doc.data()['imageUrls']}");
          } catch (parseError) {
            print("Error parsing post ${doc.id}: $parseError");
            print("Post data: ${doc.data()}");
          }
        }

        print("Successfully parsed ${_userPosts.length} posts");

        emit(
          PostLoaded(
            posts: _posts,
            likedPosts: _likedPosts,
            commentCounts: _commentCounts,
            userPosts: _userPosts,
          ),
        );
      } catch (e) {
        emit(PostError("Không thể tải bài đăng của người dùng: $e"));
      }
    });

    on<LikePostEvent>((event, emit) async {
      try {
        final postRef = _firestore.collection('posts').doc(event.postId);
        final postIndex = _posts.indexWhere((post) => post.id == event.postId);
        final userPostIndex = _userPosts.indexWhere((post) => post.id == event.postId);

        if (_likedPosts.contains(event.postId)) {
          _likedPosts.remove(event.postId);
          await postRef.update({'likeCount': FieldValue.increment(-1)});
          if (postIndex != -1) {
            _posts[postIndex] = _posts[postIndex].copyWith(
              likeCount: _posts[postIndex].likeCount - 1,
            );
          }
          if (userPostIndex != -1) {
            _userPosts[userPostIndex] = _userPosts[userPostIndex].copyWith(
              likeCount: _userPosts[userPostIndex].likeCount - 1,
            );
          }
        } else {
          _likedPosts.add(event.postId);
          await postRef.update({'likeCount': FieldValue.increment(1)});
          if (postIndex != -1) {
            _posts[postIndex] = _posts[postIndex].copyWith(
              likeCount: _posts[postIndex].likeCount + 1,
            );
          }
          if (userPostIndex != -1) {
            _userPosts[userPostIndex] = _userPosts[userPostIndex].copyWith(
              likeCount: _userPosts[userPostIndex].likeCount + 1,
            );
          }
        }

        emit(
          PostLoaded(
            posts: _posts,
            likedPosts: _likedPosts,
            commentCounts: _commentCounts,
            userPosts: _userPosts,
          ),
        );
      } catch (e) {
        emit(PostError("Không thể thích bài đăng: $e"));
      }
    });

    on<RefreshPostsEvent>((event, emit) async {
      add(FetchPostsEvent());
    });

    on<UpdateCommentCountEvent>((event, emit) async {
      try {
        final postDoc = await _firestore.collection('posts').doc(event.postId).get();
        final data = postDoc.data() as Map<String, dynamic>?;
        _commentCounts[event.postId] = data?['commentCount'] ?? 0;

        emit(
          PostLoaded(
            posts: _posts,
            likedPosts: _likedPosts,
            commentCounts: _commentCounts,
            userPosts: _userPosts,
          ),
        );
      } catch (e) {
        emit(PostError("Không thể cập nhật số lượng bình luận: $e"));
      }
    });

    on<UpdateCommentCountsEvent>((event, emit) async {
      try {
        _commentCounts.addAll(event.updatedCommentCounts);
        emit(
          PostLoaded(
            posts: _posts,
            likedPosts: _likedPosts,
            commentCounts: _commentCounts,
            userPosts: _userPosts,
          ),
        );
      } catch (e) {
        emit(PostError("Không thể cập nhật số lượng bình luận: $e"));
      }
    });
  }

  Future<int> getCommentCount(String postId) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();
    return snapshot.docs.length;
  }

  Future<User> getUserByPost(String postId) async {
    final postSnapshot = await _firestore.collection('posts').doc(postId).get();

    if (!postSnapshot.exists) {
      throw Exception('Post không tồn tại');
    }

    final postData = postSnapshot.data() as Map<String, dynamic>;
    final userId = postData['userId'];

    if (userId == null) {
      throw Exception('Post không có userId');
    }

    final userSnapshot = await _firestore.collection('users').doc(userId).get();

    if (!userSnapshot.exists) {
      throw Exception('User không tồn tại');
    }

    return User.fromFirestore(userSnapshot);
  }

  Future<List<Post>> fetchPostsForUser(String userId) async {
    try {
      final postsSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get();
      return postsSnapshot.docs.map((doc) => Post.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      debugPrint('UserBloc: Lỗi khi lấy bài đăng cho userId: $userId, lỗi: $e');
      return [];
    }
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/domain/models/Post.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> _posts = [];
  Set<String> _likedPosts = {};
  Map<String, int> _commentCounts = {}; // Map postId -> comment count

  PostBloc() : super(PostInitial()) {
    on<FetchPostsEvent>((event, emit) async {
      emit(PostLoading());
      try {
        final snapshot =
            await _firestore
                .collection('posts')
                .orderBy('createdAt', descending: true)
                .limit(20)
                .get();

        _posts =
            snapshot.docs
                .map((doc) => Post.fromMap(doc.id, doc.data()))
                .toList();

        // Tính comment count cho mỗi post
        _commentCounts = {};
        for (var post in _posts) {
          final count = await getCommentCount(post.id);
          _commentCounts[post.id] = count;
        }

        emit(
          PostLoaded(
            posts: _posts,
            likedPosts: _likedPosts,
            commentCounts: _commentCounts, // thêm vào state
          ),
        );
      } catch (e) {
        emit(PostError("Không thể tải bài đăng: $e"));
      }
    });

    on<LikePostEvent>((event, emit) async {
      try {
        final postRef = _firestore.collection('posts').doc(event.postId);
        final postIndex = _posts.indexWhere((post) => post.id == event.postId);

        if (_likedPosts.contains(event.postId)) {
          _likedPosts.remove(event.postId);
          await postRef.update({'likeCount': FieldValue.increment(-1)});
          if (postIndex != -1) {
            _posts[postIndex] = _posts[postIndex].copyWith(
              likeCount: _posts[postIndex].likeCount - 1,
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
        }

        emit(
          PostLoaded(
            posts: _posts,
            likedPosts: _likedPosts,
            commentCounts: _commentCounts,
          ),
        );
      } catch (e) {
        emit(PostError("Không thể thích bài đăng: $e"));
      }
    });

    on<RefreshPostsEvent>((event, emit) async {
      add(FetchPostsEvent());
    });
  }

  Future<int> getCommentCount(String postId) async {
    final snapshot =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .get();
    return snapshot.docs.length;
  }
}

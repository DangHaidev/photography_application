import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/design_systems/design_system_export.dart';
import '../../../core/domain/models/Post.dart';
import '../../blocs/follow/follow_bloc.dart';
import '../../blocs/follow/follow_state.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> _posts = [];
  Set<String> _likedPosts = {};
  Map<String, int> _commentCounts = {};
  DocumentSnapshot? _lastDocument;
  bool _hasMorePosts = true;

  PostBloc() : super(PostInitial()) {
    on<FetchPostsEvent>((event, emit) async {
      emit(PostLoading());
      try {
        _posts = [];
        _lastDocument = null;
        _hasMorePosts = true;

        Query query = _firestore
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .limit(10);

        if (event.isFollowingTab && event.context != null) {
          final followBloc = event.context!.read<FollowBloc>();
          if (followBloc.state is FollowSuccessState) {
            final followingUserIds = (followBloc.state as FollowSuccessState).followings;
            if (followingUserIds.isNotEmpty) {
              query = query.where('userId', whereIn: followingUserIds);
            } else {
              _posts = [];
              _hasMorePosts = false;
              emit(
                PostLoaded(
                  posts: _posts,
                  likedPosts: _likedPosts,
                  commentCounts: _commentCounts,
                  hasMore: _hasMorePosts,
                ),
              );
              return;
            }
          }
        }

        final snapshot = await query.get();
        _posts = snapshot.docs
            .map((doc) => Post.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();

        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMorePosts = snapshot.docs.length == 10;

        _commentCounts = {};
        for (var post in _posts) {
          _commentCounts[post.id] = await getCommentCount(post.id);
        }

        emit(
          PostLoaded(
            posts: _posts,
            likedPosts: _likedPosts,
            commentCounts: _commentCounts,
            hasMore: _hasMorePosts,
          ),
        );
      } catch (e) {
        debugPrint('PostBloc: Error fetching posts: $e');
        emit(PostError("Không thể tải bài đăng: $e"));
      }
    });

    on<FetchMorePostsEvent>((event, emit) async {
      if (!_hasMorePosts) {
        debugPrint('PostBloc: No more posts to fetch');
        return;
      }

      try {
        Query query = _firestore
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_lastDocument!)
            .limit(10);

        if (event.isFollowingTab) {
          final followBloc = event.context.read<FollowBloc>();
          if (followBloc.state is FollowSuccessState) {
            final followingUserIds = (followBloc.state as FollowSuccessState).followings;
            if (followingUserIds.isNotEmpty) {
              query = query.where('userId', whereIn: followingUserIds);
            } else {
              debugPrint('PostBloc: No following users, skipping fetch');
              return;
            }
          }
        }

        final snapshot = await query.get();
        final newPosts = snapshot.docs
            .map((doc) => Post.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();

        _posts.addAll(newPosts);
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMorePosts = snapshot.docs.length == 10;

        for (var post in newPosts) {
          _commentCounts[post.id] = await getCommentCount(post.id);
        }

        debugPrint('PostBloc: Emitted PostLoaded with ${_posts.length} posts after fetching more');
        emit(
          PostLoaded(
            posts: _posts,
            likedPosts: _likedPosts,
            commentCounts: _commentCounts,
            hasMore: _hasMorePosts,
          ),
        );
      } catch (e) {
        debugPrint('PostBloc: Error fetching more posts: $e');
        emit(PostError("Không thể tải thêm bài đăng: $e"));
      }
    });

    on<LikePostEvent>((event, emit) async {
      try {
        final postRef = _firestore.collection('posts').doc(event.postId);
        final postIndex = _posts.indexWhere((post) => post.id == event.postId);

        if (postIndex == -1) {
          debugPrint('PostBloc: Post ${event.postId} not found in current list');
          return; // Skip if post is not in the current list
        }

        if (_likedPosts.contains(event.postId)) {
          _likedPosts.remove(event.postId);
          await postRef.update({'likeCount': FieldValue.increment(-1)});
          _posts[postIndex] = _posts[postIndex].copyWith(
            likeCount: _posts[postIndex].likeCount - 1,
          );
        } else {
          _likedPosts.add(event.postId);
          await postRef.update({'likeCount': FieldValue.increment(1)});
          _posts[postIndex] = _posts[postIndex].copyWith(
            likeCount: _posts[postIndex].likeCount + 1,
          );
        }

        debugPrint('PostBloc: Emitted PostLoaded after liking post ${event.postId}');
        emit(
          PostLoaded(
            posts: _posts,
            likedPosts: _likedPosts,
            commentCounts: _commentCounts,
            hasMore: _hasMorePosts,
          ),
        );
      } catch (e) {
        debugPrint('PostBloc: Error liking post ${event.postId}: $e');
        emit(PostError("Không thể thích bài đăng: $e"));
      }
    });

    on<RefreshPostsEvent>((event, emit) async {
      debugPrint('PostBloc: Refreshing posts');
      add(FetchPostsEvent());
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
}
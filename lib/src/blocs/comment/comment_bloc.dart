import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/domain/models/Comment.dart';
import '../post/post_bloc.dart';
import '../post/post_event.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PostBloc _postBloc; // Thêm PostBloc để gửi sự kiện
  final Map<String, List<Comment>> _comments = {}; // Bộ nhớ local

  CommentBloc(this._postBloc) : super(CommentInitial()) {
    on<FetchCommentsEvent>((event, emit) async {
      emit(CommentLoading());
      try {
        final snapshot = await _firestore
            .collection('posts')
            .doc(event.postId)
            .collection('comments')
            .orderBy('createdAt', descending: true)
            .get();

        final comments = snapshot.docs.map((doc) {
          final data = doc.data();
          return Comment(
            id: doc.id,
            userId: data['userId'],
            content: data['content'],
            createdAt: data['createdAt'],
            likeCount: data['likeCount'] ?? 0,
          );
        }).toList();

        _comments[event.postId] = comments;
        emit(CommentLoaded(Map.from(_comments)));
      } catch (e) {
        emit(CommentError("Lỗi khi tải bình luận: $e"));
      }
    });

    on<AddCommentEvent>((event, emit) async {
      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) {
          emit(CommentError("Vui lòng đăng nhập để bình luận."));
          return;
        }

        final commentRef = _firestore
            .collection('posts')
            .doc(event.postId)
            .collection('comments')
            .doc();

        final newComment = Comment(
          id: commentRef.id,
          userId: currentUserId,
          content: event.content,
          createdAt: Timestamp.now(),
          likeCount: 0,
        );

        await commentRef.set({
          'userId': newComment.userId,
          'content': newComment.content,
          'createdAt': newComment.createdAt,
          'likeCount': newComment.likeCount,
        });

        // Đếm lại số bình luận và cập nhật commentCount trong Firestore
        final commentCount = await getCommentCount(event.postId);
        await _firestore.collection('posts').doc(event.postId).update({
          'commentCount': commentCount,
        });

        // Gửi sự kiện tới PostBloc để cập nhật _commentCounts
        _postBloc.add(UpdateCommentCountEvent(event.postId));

        // Cập nhật danh sách bình luận trong bộ nhớ local
        _comments[event.postId] = [
          newComment,
          ...(_comments[event.postId] ?? []),
        ];
        emit(CommentLoaded(Map.from(_comments)));
      } catch (e) {
        emit(CommentError("Không thể thêm bình luận: $e"));
      }
    });

    on<DeleteCommentEvent>((event, emit) async {
      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) {
          emit(CommentError("Vui lòng đăng nhập để xóa bình luận."));
          return;
        }

        // Kiểm tra quyền xóa (chỉ người tạo bình luận được xóa)
        final commentDoc = await _firestore
            .collection('posts')
            .doc(event.postId)
            .collection('comments')
            .doc(event.commentId)
            .get();
        if (!commentDoc.exists || commentDoc.data()!['userId'] != currentUserId) {
          emit(CommentError("Bạn không có quyền xóa bình luận này."));
          return;
        }

        await _firestore
            .collection('posts')
            .doc(event.postId)
            .collection('comments')
            .doc(event.commentId)
            .delete();

        // Đếm lại số bình luận và cập nhật commentCount trong Firestore
        final commentCount = await getCommentCount(event.postId);
        await _firestore.collection('posts').doc(event.postId).update({
          'commentCount': commentCount,
        });

        // Gửi sự kiện tới PostBloc để cập nhật _commentCounts
        _postBloc.add(UpdateCommentCountEvent(event.postId));

        // Cập nhật danh sách bình luận trong bộ nhớ local
        _comments[event.postId] = (_comments[event.postId] ?? [])
            .where((comment) => comment.id != event.commentId)
            .toList();
        emit(CommentLoaded(Map.from(_comments)));
      } catch (e) {
        emit(CommentError("Không thể xóa bình luận: $e"));
      }
    });

    on<LikeCommentEvent>((event, emit) async {
      try {
        final ref = _firestore
            .collection('posts')
            .doc(event.postId)
            .collection('comments')
            .doc(event.commentId);

        await ref.update({'likeCount': FieldValue.increment(1)});

        // Cập nhật local state
        final list = _comments[event.postId];
        if (list != null) {
          final index = list.indexWhere((c) => c.id == event.commentId);
          if (index != -1) {
            list[index] = list[index].copyWith(
              likeCount: list[index].likeCount + 1,
            );
            emit(CommentLoaded(Map.from(_comments)));
          }
        }
      } catch (e) {
        emit(CommentError("Không thể thích bình luận: $e"));
      }
    });

    on<FetchCommentCountsEvent>((event, emit) async {
      try {
        Map<String, int> commentCounts = {};
        for (final postId in event.postIds) {
          final snapshot = await _firestore
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .get();
          commentCounts[postId] = snapshot.docs.length;
        }
        // Gửi sự kiện tới PostBloc để cập nhật _commentCounts
        _postBloc.add(UpdateCommentCountsEvent(commentCounts));
        emit(CommentLoaded(Map.from(_comments)));
      } catch (e) {
        emit(CommentError("Lỗi khi tải số lượng bình luận: $e"));
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
}
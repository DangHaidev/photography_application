import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'comment_event.dart';
import 'comment_state.dart';
import '../../../core/domain/models/Comment.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, List<Comment>> _comments = {}; // Bộ nhớ local

  CommentBloc() : super(CommentInitial()) {
    on<FetchCommentsEvent>((event, emit) async {
      emit(CommentLoading());
      try {
        final snapshot =
            await _firestore
                .collection('posts')
                .doc(event.postId)
                .collection('comments')
                .orderBy('createdAt', descending: true)
                .get();

        final comments =
            snapshot.docs.map((doc) {
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
        final commentRef =
            _firestore
                .collection('posts')
                .doc(event.postId)
                .collection('comments')
                .doc();

        final newComment = Comment(
          id: commentRef.id,
          userId: event.userId,
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

        _comments[event.postId]?.insert(0, newComment);
        emit(CommentLoaded(Map.from(_comments)));
      } catch (e) {
        emit(CommentError("Không thể thêm bình luận: $e"));
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
        for (final postId in event.postIds) {
          final snapshot =
              await _firestore
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .get();

          final comments =
              snapshot.docs.map((doc) {
                final data = doc.data();
                return Comment(
                  id: doc.id,
                  userId: data['userId'],
                  content: data['content'],
                  createdAt: data['createdAt'],
                  likeCount: data['likeCount'] ?? 0,
                );
              }).toList();

          _comments[postId] = comments;
        }
        emit(CommentLoaded(Map.from(_comments)));
      } catch (e) {
        emit(CommentError("Lỗi khi tải số lượng bình luận: $e"));
      }
    });
  }
}

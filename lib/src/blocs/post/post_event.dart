import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PostEvent {}

class FetchPostsEvent extends PostEvent {
  final DocumentSnapshot? startAfter; // Thêm tham số để hỗ trợ phân trang
  FetchPostsEvent({this.startAfter});
}

class LikePostEvent extends PostEvent {
  final String postId;

  LikePostEvent(this.postId);
}

class RefreshPostsEvent extends PostEvent {}

class FetchUserPostsEvent extends PostEvent {
  final String userId;

  FetchUserPostsEvent(this.userId);
}

class UpdateCommentCountEvent extends PostEvent {
  final String postId;
  UpdateCommentCountEvent(this.postId);
}

class UpdateCommentCountsEvent extends PostEvent {
  final Map<String, int> updatedCommentCounts;
  UpdateCommentCountsEvent(this.updatedCommentCounts);
}
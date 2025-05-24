abstract class CommentEvent {}

class FetchCommentsEvent extends CommentEvent {
  final String postId;

  FetchCommentsEvent(this.postId);
}

class AddCommentEvent extends CommentEvent {
  final String postId;
  final String content;
  final String userId;

  AddCommentEvent({
    required this.postId,
    required this.content,
    required this.userId,
  });
}

class LikeCommentEvent extends CommentEvent {
  final String postId;
  final String commentId;

  LikeCommentEvent({required this.postId, required this.commentId});
}


class FetchCommentCountsEvent extends CommentEvent {
  final List<String> postIds;
  FetchCommentCountsEvent({required this.postIds});
}


class DeleteCommentEvent extends CommentEvent {
  final String postId;
  final String commentId;
  DeleteCommentEvent(this.postId, this.commentId);
}
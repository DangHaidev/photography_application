abstract class PostEvent {}

class FetchPostsEvent extends PostEvent {}

class LikePostEvent extends PostEvent {
  final String postId;

  LikePostEvent(this.postId);
}

class RefreshPostsEvent extends PostEvent {}

class FetchUserPostsEvent extends PostEvent {
  final String userId;

  FetchUserPostsEvent(this.userId);
}
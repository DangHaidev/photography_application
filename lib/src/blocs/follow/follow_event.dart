abstract class FollowEvent {}

class FollowUserEvent extends FollowEvent {
  final String followerId;
  final String followingId;

  FollowUserEvent({required this.followerId, required this.followingId});
}

class UnfollowUserEvent extends FollowEvent {
  final String followerId;
  final String followingId;

  UnfollowUserEvent({required this.followerId, required this.followingId});
}

class FetchFollowingsEvent extends FollowEvent {
  final String userId;

  FetchFollowingsEvent({required this.userId});
}

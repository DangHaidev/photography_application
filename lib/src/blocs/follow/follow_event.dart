import '../../../core/domain/models/User.dart';

abstract class FollowEvent {}

class FollowUserEvent extends FollowEvent {
  final String followerId;
  final String followingId;
  FollowUserEvent(this.followerId, this.followingId);
}

class UnfollowUserEvent extends FollowEvent {
  final String followerId;
  final String followingId;
  UnfollowUserEvent(this.followerId, this.followingId);
}

class FetchFollowingsEvent extends FollowEvent {
  final String userId;
  FetchFollowingsEvent({required this.userId});
}

class FetchFollowerCountEvent extends FollowEvent {
  final String userId;
  final User user; // Include User object
  FetchFollowerCountEvent(this.userId, this.user);
}
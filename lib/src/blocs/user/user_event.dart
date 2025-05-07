abstract class UserEvent {}

class FetchUserInfoEvent extends UserEvent {
  final String userId;

  FetchUserInfoEvent(this.userId);
}

class FetchUserFollowingsEvent extends UserEvent {
  final String userId;

  FetchUserFollowingsEvent(this.userId);
}
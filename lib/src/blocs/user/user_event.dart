abstract class UserEvent {
  const UserEvent();

  List<Object?> get props => [];
}

class FetchUserInfoEvent extends UserEvent {
  final String userId;

  FetchUserInfoEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchUserFollowingsEvent extends UserEvent {
  final String userId;

  FetchUserFollowingsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserStatsEvent extends UserEvent {
  final String userId;

  UpdateUserStatsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
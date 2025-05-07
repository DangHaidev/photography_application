abstract class UserState {}

class UserInitialState extends UserState {}

class UserLoadingState extends UserState {
  final String userId;

  UserLoadingState(this.userId);
}

class UserInfoLoadedState extends UserState {
  final Map<String, Map<String, dynamic>> users;

  UserInfoLoadedState(this.users);
}

class UserErrorState extends UserState {
  final String message;

  UserErrorState(this.message);
}

class UserFollowingsLoadedState extends UserState {
  final List<String> followings;

  UserFollowingsLoadedState(this.followings);
}